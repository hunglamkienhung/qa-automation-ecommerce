"""The live site's public API: automationexercise.com/api. Mirror of
node/be/api/venues/site.js. Answers HTTP 200 with a responseCode in the body;
the assertions read that field. Transport failure is SiteUnreachable.
"""

from __future__ import annotations

import json
import os
import re
import urllib.error
import urllib.parse
import urllib.request

BASE = os.environ.get("SITE_API_URL", "https://automationexercise.com/api").rstrip("/")
USER_AGENT = "qa-automation-ecommerce/1.0 (read-only invariants)"
TIMEOUT = 25


class SiteUnreachable(Exception):
    pass


def request(method, path, form=None):
    headers = {"user-agent": USER_AGENT, "accept": "application/json"}
    data = None
    if form is not None:
        headers["content-type"] = "application/x-www-form-urlencoded"
        data = urllib.parse.urlencode(form).encode()
    req = urllib.request.Request(BASE + path, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as res:
            status, text = res.status, res.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as err:
        if err.code >= 500 or err.code in (429, 403):
            raise SiteUnreachable(f"{method} {path} -- HTTP {err.code}") from err
        status, text = err.code, err.read().decode("utf-8", "replace")
    except (urllib.error.URLError, TimeoutError, OSError) as err:
        raise SiteUnreachable(f"{method} {path} -- {err}") from err
    # From some runner IPs the JSON API answers 200 with an HTML challenge page;
    # a non-JSON body is the site being unavailable, not wrong -- grade Blocked.
    try:
        body = json.loads(text)
    except json.JSONDecodeError:
        body = None
    if not isinstance(body, dict):
        raise SiteUnreachable(f"{method} {path} -- expected JSON, got " + " ".join(text[:40].split()) + "…")
    return {"httpStatus": status, "body": body, "responseCode": body.get("responseCode")}


def products_list():
    return request("GET", "/productsList")


def brands_list():
    return request("GET", "/brandsList")


def search_product(term):
    return request("POST", "/searchProduct", None if term is None else {"search_product": term})


def verify_login(form):
    return request("POST", "/verifyLogin", form)


def products_list_post():
    return request("POST", "/productsList")


def brands_list_post():
    return request("POST", "/brandsList")


def get_user_by_email(email):
    return request("GET", "/getUserDetailByEmail?email=" + urllib.parse.quote(email))


def parse_price(s):
    m = re.match(r"^Rs\.\s*(\d+)$", str(s).strip())
    return int(m.group(1)) if m else None
