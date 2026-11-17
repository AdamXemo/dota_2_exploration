# Dev tool: full-page screenshots of the running Shiny app via the Chrome DevTools
# Protocol, with REAL waiting (headless Chrome's --virtual-time-budget runs faster than
# the Shiny websocket, which made pages like Item Codex look empty).
# Needs: google-chrome and the python "websocket-client" package.
# 1) start the app:   Rscript -e 'shiny::runApp("app", port = 4470)'
# 2) screenshot:      python3 tools/screenshot.py http://127.0.0.1:4470 /tmp/shots home= home_phone=@390 meta=?tab=meta items=?tab=items
#    each job is name=query[@width]; output files are <out>/ux_<name>.png
import json, subprocess, sys, time, base64, urllib.request, websocket, tempfile, os

base, out = sys.argv[1], sys.argv[2]
jobs = sys.argv[3:]
port = 9333
prof = tempfile.mkdtemp()
chrome = subprocess.Popen(["google-chrome", "--headless=new", "--disable-gpu", "--hide-scrollbars",
                           f"--remote-debugging-port={port}", f"--user-data-dir={prof}", "about:blank"],
                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
for _ in range(50):
    try:
        tabs = json.load(urllib.request.urlopen(f"http://127.0.0.1:{port}/json"))
        page = [t for t in tabs if t["type"] == "page"][0]
        break
    except Exception:
        time.sleep(0.2)
ws = websocket.create_connection(page["webSocketDebuggerUrl"], timeout=60)
mid = [0]
def call(method, **params):
    mid[0] += 1
    ws.send(json.dumps({"id": mid[0], "method": method, "params": params}))
    while True:
        msg = json.loads(ws.recv())
        if msg.get("id") == mid[0]:
            return msg.get("result", {})
call("Page.enable"); call("Runtime.enable")
for job in jobs:
    name, spec = job.split("=", 1)
    width = 1500
    if "@" in spec:
        spec, w = spec.split("@"); width = int(w)
    mobile = width < 600
    call("Emulation.setDeviceMetricsOverride", width=width, height=1000, deviceScaleFactor=1, mobile=mobile)
    call("Page.navigate", url=base + "/" + spec)
    time.sleep(7)
    errs = call("Runtime.evaluate", expression="Array.from(document.querySelectorAll('.shiny-output-error')).map(e=>e.innerText).join(' | ')", returnByValue=True)
    h = call("Runtime.evaluate", expression="Math.max(document.body.scrollHeight, document.documentElement.scrollHeight)", returnByValue=True)["result"]["value"]
    call("Emulation.setDeviceMetricsOverride", width=width, height=min(int(h), 9000), deviceScaleFactor=1, mobile=mobile)
    time.sleep(1.5)
    sw = call("Runtime.evaluate", expression="document.documentElement.scrollWidth", returnByValue=True)["result"]["value"]
    data = call("Page.captureScreenshot", format="png")["data"]
    p = os.path.join(out, f"ux_{name}.png")
    open(p, "wb").write(base64.b64decode(data))
    print(p, "height", h, "scrollWidth", sw, "errors:", errs["result"].get("value"))
chrome.kill()
