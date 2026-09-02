#!/usr/bin/env python3
"""Generate crawlable static HTML for ForgeLine Academy course slugs and Search landings.

Copy is first-pass plant-floor outline for Bailey/Marketing. Do not invent testimonials.
"""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "public"
SITE = "https://forgelineacademy.com"
PHONE = "+1 580 421 5714"
PHONE_TEL = "+15804215714"
EMAIL = "support@forgelineacademy.com"
ORG = "ForgeLine Academy"
LASTMOD = "2026-09-02"

STAGE_LABEL = {
    "mechanical": "Mechanical path",
    "electrical": "Electrical path",
    "ie": "I&E path",
    "engineering": "Engineering path",
}

LANDINGS = [
    {
        "path": "/vfd-ground-fault",
        "slug": "vfd-ground-fault",
        "title": "VFD Ground Fault Troubleshooting — ForgeLine Academy",
        "h1": "VFD ground fault troubleshooting on the plant floor",
        "description": "Plant-floor method for VFD ground-fault trips: insulation, motor leads, wet windings, and why a ground fault is not an overcurrent. Free Electrical training from ForgeLine Academy.",
        "related": [
            ("/courses/vfd-fundamentals-parameterization", "VFD Fundamentals & Parameterization"),
            ("/courses/vfd-installation-commissioning", "VFD Installation & Commissioning"),
            ("/vfd-overcurrent", "VFD overcurrent vs ground fault"),
            ("/paths/electrical", "Electrical path"),
        ],
    },
    {
        "path": "/vfd-overcurrent",
        "slug": "vfd-overcurrent",
        "title": "VFD Overcurrent Troubleshooting — ForgeLine Academy",
        "h1": "VFD overcurrent trips: bind, ramp, and motor data",
        "description": "How plant electricians separate a VFD overcurrent trip from a ground fault. Accel time, mechanical bind, motor FLA, and parameterization for this motor — not reset-and-hope.",
        "related": [
            ("/courses/vfd-fundamentals-parameterization", "VFD Fundamentals & Parameterization"),
            ("/vfd-ground-fault", "VFD ground fault"),
            ("/courses/industrial-motor-control-circuits", "Industrial Motor Control Circuits"),
            ("/paths/electrical", "Electrical path"),
        ],
    },
    {
        "path": "/motor-megger",
        "slug": "motor-megger",
        "title": "Motor Megger & Polarization Index — ForgeLine Academy",
        "h1": "Motor megger and polarization index the way the log should read",
        "description": "Plant-floor megger and PI testing for motors: 500 / 1000 / 5000 V, the 10-minute vs 1-minute reading, wet leads, and an honest pass/fail. Free Electrical course.",
        "related": [
            ("/courses/motor-testing-with-megger-pi", "Motor Testing with Megger & PI"),
            ("/paths/electrical", "Electrical path"),
            ("/courses/3-phase-power-systems-and-troubleshooting", "3-Phase Power Systems"),
            ("/vfd-ground-fault", "VFD ground fault"),
        ],
    },
    {
        "path": "/control-valve-troubleshooting",
        "slug": "control-valve-troubleshooting",
        "title": "Control Valve Troubleshooting — ForgeLine Academy",
        "h1": "Control valve troubleshooting when the valve will not stroke",
        "description": "Plant-floor control valve diagnostics: air to the positioner, bench set, stiction, signature, and why a 4-20 mA command is not proof the valve moved. I&E training from ForgeLine Academy.",
        "related": [
            ("/courses/control-valve-calibration-and-diagnostics", "Control Valve Calibration & Diagnostics"),
            ("/courses/smart-valve-positioners-and-digital-feedback", "Smart Valve Positioners"),
            ("/4-20ma-loop-troubleshooting", "4-20 mA loop troubleshooting"),
            ("/catalog", "Course catalog"),
        ],
    },
    {
        "path": "/4-20ma-loop-troubleshooting",
        "slug": "4-20ma-loop-troubleshooting",
        "title": "4-20 mA Loop Troubleshooting — ForgeLine Academy",
        "h1": "4-20 mA loop troubleshooting: 3.8 mA fail-low and a dead transmitter",
        "description": "How I&E techs walk a 4-20 mA loop: supply, loop resistance, fail-low at 3.8 mA, HART vs analog, and why a DCS reading is not the same as a meter in series.",
        "related": [
            ("/courses/hart-transmitters-and-smart-instrumentation", "HART Transmitters & Smart Instrumentation"),
            ("/courses/pressure-measurement-and-transmitters", "Pressure Measurement & Transmitters"),
            ("/control-valve-troubleshooting", "Control valve troubleshooting"),
            ("/ie-technician", "I&E technician training"),
        ],
    },
    {
        "path": "/paths/mechanical",
        "slug": "paths-mechanical",
        "title": "Mechanical Path — Plant-Floor Millwright Training | ForgeLine Academy",
        "h1": "Mechanical path: bearings, lubrication, alignment, pumps, and rotating equipment",
        "description": "Free Mechanical path from ForgeLine Academy. 22 free millwright courses starting with bearings, lubrication, and shaft alignment. 44 free courses overall, 78 total in the catalog.",
        "related": [
            ("/courses/bearings-lubrication-alignment-fundamentals", "Bearings, Lubrication & Alignment"),
            ("/courses/pump-and-mechanical-seal-maintenance", "Pump & Mechanical Seal Maintenance"),
            ("/paths", "All learning paths"),
            ("/catalog", "Course catalog"),
        ],
    },
    {
        "path": "/paths/electrical",
        "slug": "paths-electrical",
        "title": "Electrical Path — Plant Electrician Training | ForgeLine Academy",
        "h1": "Electrical path: motor megger, VFDs, starters, and plant power",
        "description": "Free Electrical path from ForgeLine Academy. 22 free industrial electrician courses: megger and PI, VFD faults, motor control, prints, and 3-phase power. 44 free / 78 total.",
        "related": [
            ("/courses/motor-testing-with-megger-pi", "Motor Testing with Megger & PI"),
            ("/courses/vfd-fundamentals-parameterization", "VFD Fundamentals & Parameterization"),
            ("/paths", "All learning paths"),
            ("/catalog", "Course catalog"),
        ],
    },
]

CSS = """
:root{--navy:#0b1220;--navy2:#111827;--steel:#94a3b8;--white:#f8fafc;--rok:#ec682b;--border:rgba(148,163,184,.25)}
*{box-sizing:border-box}body{margin:0;font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;background:var(--navy);color:var(--white);line-height:1.6}
a{color:var(--rok);text-decoration:none}a:hover{text-decoration:underline}
.wrap{max-width:880px;margin:0 auto;padding:28px 20px 64px}
.brand{font-weight:800;letter-spacing:.02em}.brand span{display:block;font-size:11px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:var(--steel)}
.nav{display:flex;gap:14px;flex-wrap:wrap;margin:18px 0 28px;font-size:14px}
.nav a{color:var(--steel)}.nav a:hover{color:var(--white)}
h1{font-size:clamp(1.75rem,4vw,2.4rem);line-height:1.15;margin:0 0 12px}
h2{font-size:1.2rem;margin:0 0 8px}
.lead{color:var(--steel);font-size:1.05rem;margin:0 0 22px;max-width:68ch}
.card{background:var(--navy2);border:1px solid var(--border);border-radius:14px;padding:20px;margin:14px 0}
.card p,.card li{color:var(--steel);font-size:.98rem}
ul{padding-left:1.15rem;margin:8px 0 0}
.cta{display:inline-flex;align-items:center;gap:8px;background:var(--rok);color:#fff!important;font-weight:700;padding:12px 18px;border-radius:10px;text-decoration:none!important;margin:6px 8px 6px 0}
.cta.secondary{background:transparent;border:1px solid var(--rok);color:var(--rok)!important}
.note{font-size:13px;color:var(--steel);margin-top:28px}
footer{margin-top:40px;padding-top:18px;border-top:1px solid var(--border);font-size:13px;color:var(--steel)}
.meta{font-size:13px;color:var(--steel);margin-bottom:10px}
"""

NAV = """
    <div class="brand">ForgeLine Academy<span>Industrial training</span></div>
    <nav class="nav" aria-label="Primary">
      <a href="/">Home</a>
      <a href="/catalog">Catalog</a>
      <a href="/paths">Paths</a>
      <a href="/paths/mechanical">Mechanical path</a>
      <a href="/paths/electrical">Electrical path</a>
      <a href="/vfd-ground-fault">VFD ground fault</a>
      <a href="/vfd-overcurrent">VFD overcurrent</a>
      <a href="/motor-megger">Motor megger</a>
      <a href="/control-valve-troubleshooting">Control valves</a>
      <a href="/4-20ma-loop-troubleshooting">4-20 mA loops</a>
      <a href="/on-site-training">On-site training</a>
    </nav>
"""

FOOT = f"""
    <p class="note">Training is educational. It does not replace your site&apos;s lockout/tagout, permits, PPE, or required licenses. Certificates of completion go in the file. They are not a license.</p>
    <footer>
      <div>&copy; 2026 {ORG} &middot; <a href="mailto:{EMAIL}">{EMAIL}</a> &middot; <a href="tel:{PHONE_TEL}">{PHONE}</a></div>
      <div>Based in Oklahoma. Travel available nationwide for on-site training and plant support.</div>
    </footer>
"""


def parse_courses() -> list[dict]:
    text = (ROOT / "src/lib/seo/courseSlugs.ts").read_text()
    blocks = re.findall(
        r'\{\s*id:\s*"([^"]+)",\s*slug:\s*"([^"]+)",\s*title:\s*"([^"]+)",\s*stage:\s*"([^"]+)",\s*tier:\s*"([^"]+)",\s*description:\s*"([^"]+)",\s*\}',
        text,
    )
    courses = []
    for cid, slug, title, stage, tier, desc in blocks:
        courses.append(
            {
                "id": cid,
                "slug": slug,
                "title": title,
                "stage": stage,
                "tier": tier,
                "description": desc,
            }
        )
    if len(courses) != 78:
        raise SystemExit(f"expected 78 courses, got {len(courses)}")
    free = sum(1 for c in courses if c["tier"] == "free")
    if free != 44:
        raise SystemExit(f"expected 44 free courses, got {free}")
    return courses


def hsh(s: str) -> int:
    return int(hashlib.sha256(s.encode()).hexdigest()[:8], 16)


def clip(text: str, max_len: int = 158) -> str:
    clean = re.sub(r"\s+", " ", text).strip()
    if len(clean) <= max_len:
        return clean
    cut = clean[:max_len]
    sp = cut.rfind(" ")
    return (cut[:sp] if sp > 80 else cut).rstrip() + "…"


def org_ld() -> dict:
    return {
        "@context": "https://schema.org",
        "@type": "Organization",
        "name": ORG,
        "url": SITE,
        "telephone": PHONE,
        "email": EMAIL,
    }


def course_ld(name: str, description: str, url: str, free: bool) -> dict:
    return {
        "@context": "https://schema.org",
        "@type": "Course",
        "name": name,
        "description": description,
        "url": url,
        "isAccessibleForFree": free,
        "provider": {
            "@type": "Organization",
            "name": ORG,
            "url": SITE,
            "telephone": PHONE,
            "email": EMAIL,
        },
    }


def html_page(title: str, description: str, canonical: str, h1: str, body_html: str, json_ld: list) -> str:
    ld = "\n".join(
        f'  <script type="application/ld+json">{json.dumps(obj, ensure_ascii=False)}</script>'
        for obj in json_ld
    )
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(description)}" />
  <link rel="canonical" href="{canonical}" />
  <meta property="og:type" content="website" />
  <meta property="og:url" content="{canonical}" />
  <meta property="og:title" content="{esc(title)}" />
  <meta property="og:description" content="{esc(description)}" />
  <meta property="og:image" content="{SITE}/og.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:image" content="{SITE}/og.png" />
{ld}
  <style>{CSS}</style>
</head>
<body>
  <div class="wrap">
{NAV}
    <h1>{esc(h1)}</h1>
{body_html}
{FOOT}
  </div>
</body>
</html>
"""


def esc(s: str) -> str:
    return (
        s.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


def related_html(pairs: list[tuple[str, str]]) -> str:
    items = "\n".join(f'      <li><a href="{href}">{esc(label)}</a></li>' for href, label in pairs)
    return f'<div class="card"><h2>Related plant-floor pages</h2><ul>\n{items}\n    </ul></div>'


def catalog_blurb() -> str:
    return (
        f"{ORG} currently lists 78 industrial maintenance courses. 44 of those are free "
        "(Mechanical and Electrical). Premium unlocks I&amp;E (18) and Engineering (16). "
        "That is the whole catalog — not a 22-course teaser and not a four-hour overview of the plant. "
        f"Call <a href=\"tel:{PHONE_TEL}\">{PHONE}</a> or email "
        f"<a href=\"mailto:{EMAIL}\">{EMAIL}</a> for plant cohorts and on-site classes."
    )


def stage_walk(course: dict) -> str:
    title = course["title"]
    stage = course["stage"]
    if stage == "mechanical":
        variants = [
            f"On a millwright call the work order often names a part, not a cause. For {title}, start with what the machine is doing: heat, noise, leak, vibration, or a trip that looks electrical until you put a hand on the coupling. Confirm isolation, then measure. Soft foot, pipe strain, lubrication that does not match the duty, and a shaft that was never aligned well enough to leave alone still fake more “bad bearings” than bad steel.",
            f"{title} is the kind of job where production wants the guard back on before lunch. That pressure is how plants skip the baseline. Take the as-found: temperature, grease condition, alignment readings, seal weep, belt tension. Write it. Then decide if the repair is a component swap or a geometry problem. Geometry problems come back on the next crew.",
            f"Most rotating equipment failures that get blamed on {title.lower()} start as a lubrication or alignment miss. The housing is the last thing to come off, not the first. Check lubrication method and interval against the actual duty. Check alignment with the coupling still telling the truth. If the numbers do not hold, the insert will not save you.",
        ]
    elif stage == "electrical":
        variants = [
            f"On an electrical call the first useful question is whether the circuit is dead, half-dead, or lying. For {title}, lock it out to your site procedure, then prove it. Voltage, current, insulation, and a print beat a reset. A VFD, a starter, and a motor will all throw a similar “it just tripped” story. The meter and the one-line separate them.",
            f"{title} is not a hunt for a magic parameter. It is a sequence: isolate energy, verify the print, measure the supply, measure the load, then change one thing. Drive faults, overload trips, and megger readings get faked when someone skips the 10-minute wait or treats a ground fault like an overcurrent. Write the as-found before you clear the fault.",
            f"Plant electricians lose time when they treat every bucket the same. {title} is the method for this class of problem: control power first, then power circuit, then the machine. A chattering coil, a wet winding, and a bound pump look similar on a hurried radio call. They do not look similar on a meter.",
        ]
    elif stage == "ie":
        variants = [
            f"I&amp;E work lives in the gap between a DCS number and a valve that did not move. For {title}, do not trust the faceplate until you have a meter in the loop or a gauge on the air. 4-20 mA, HART, positioner air, and process taps fail in different ways. Fail-low at 3.8 mA is a story. A plugged impulse line is a different story.",
            f"{title} starts at the field device, not the graphic. Confirm supply, loop resistance, and whether the transmitter is talking analog only or HART. If the valve will not stroke, prove air, prove the command, then prove the mechanicals. Signature and stiction come after the obvious, not instead of it.",
            f"Calibration without as-found data is a guess. {title} is how you keep the loop honest: isolate, vent, equalize, apply a known input, and record as-found / as-left. Then walk the wiring. A 3.8 mA fail-low, a reversed polarity, and a wet junction box still account for more “bad transmitters” than a failed sensor.",
        ]
    else:
        variants = [
            f"Engineering work on the plant floor still has to survive a night shift. {title} is useful only if a technician can maintain what you design: tag names, network segments, safety functions, and a commissioning checklist that matches the as-built. Pretty drawings that do not match the panel are how plants inherit undocumented logic.",
            f"{title} is the layer above the wrench: architecture, alarm philosophy, functional safety, and the network the PLC actually rides. The test is whether operations can run it and maintenance can find the routine. If the only person who understands the AOI left last quarter, the design was not done.",
            f"For {title}, start with the as-running system, not a greenfield slide. Document tasks, programs, I/O, and the safety function as it is, then change it on purpose. FAT/SAT, loop checks, and a punch list beat a “we’ll tune it after startup” promise.",
        ]
    return variants[hsh(course["slug"]) % len(variants)]


def extra_topic(course: dict) -> str:
    slug = course["slug"]
    title = course["title"]
    bits = []
    s = slug + " " + title.lower()
    if "vfd" in s or "variable-frequency" in s:
        bits.append(
            "A ground-fault trip and an overcurrent trip are not interchangeable. Overcurrent is often mechanical bind, a short accel, or motor data that does not match the nameplate. Ground fault is insulation, a damaged motor lead, a wet winding, or a long cable that the drive is finally seeing. Reset-and-hope takes a feeder. Parameterize this motor, this cable, this load — not last month’s identical-looking pump."
        )
    if "megger" in s or "polarization" in s:
        bits.append(
            "A one-minute poke at 500 V with wet leads is how plants fake a pass. Polarization index is the 10-minute reading over the 1-minute reading. Discharge the winding. Watch humidity and a hot motor. Write the voltage, the connection, and the number. If the log cannot be defended in a meeting, it was not a test."
        )
    if "valve" in s:
        bits.append(
            "If the valve will not stroke, prove instrument air at the positioner, prove the 4-20 mA command at the terminals, then prove the stem actually moved. Bench set and signature come after that. Stiction and hysteresis show up in service, not on a workbench with the actuator off the body."
        )
    if "4-20" in s or "hart" in s or "transmitter" in s or "loop" in s:
        bits.append(
            "Walk the loop with a meter. Confirm 24 V at the supply, loop resistance, and whether you are looking at analog only or a HART overlay. 3.8 mA fail-low is a configured fail state, not a mystery. A DCS graphic that says 52% is not a measurement until the field agrees."
        )
    if "bearing" in s or "lubric" in s or "align" in s:
        bits.append(
            "Most “bearing failures” on the plant floor are lubrication or alignment. The procedure millwrights actually run happens before anyone pulls a housing: what the bearing is telling you, grease that matches the duty, and an alignment you can defend."
        )
    if "motor control" in s or "starter" in s or "contactor" in s:
        bits.append(
            "A chattering starter is a coil, an overlay, or voltage. It is not automatically a welded contact. Check coil voltage under load, the seal-in, a loose control transformer, and the heater class before you condemn the bucket."
        )
    if "pump" in s or "seal" in s:
        bits.append(
            "Cavitation, a dry-run, and a flush plan that was never piped will kill a seal faster than a cheap face. Confirm suction, alignment, and the actual API plan before you order another cartridge."
        )
    if not bits:
        desc = course["description"]
        bits.append(
            f"The useful version of {title} is the version you can run on nights without a specialist on the radio. {desc} Keep the as-found. Change one variable. Hand the next crew a log, not a story."
        )
    return " ".join(bits)


def course_body(course: dict, courses: list[dict]) -> str:
    title = course["title"]
    desc = course["description"]
    stage = course["stage"]
    tier = course["tier"]
    same = [c for c in courses if c["stage"] == stage and c["slug"] != course["slug"]]
    idx = hsh(course["slug"])
    related = same[idx % max(len(same), 1) : idx % max(len(same), 1) + 3]
    if len(related) < 3:
        related = (related + same)[:3]
    access = "Free" if tier == "free" else "Premium"
    player = f"/course/{course['id']}"
    pretty = f"/courses/{course['slug']}"
    related_pairs = [(f"/courses/{c['slug']}", c["title"]) for c in related]
    if stage == "mechanical":
        related_pairs.append(("/paths/mechanical", "Mechanical path landing"))
    elif stage == "electrical":
        related_pairs.append(("/paths/electrical", "Electrical path landing"))
    related_pairs.extend(
        [
            ("/vfd-ground-fault", "VFD ground fault"),
            ("/motor-megger", "Motor megger"),
            ("/control-valve-troubleshooting", "Control valve troubleshooting"),
            ("/4-20ma-loop-troubleshooting", "4-20 mA loop troubleshooting"),
        ]
    )
    # de-dupe preserve order
    seen = set()
    uniq = []
    for href, label in related_pairs:
        if href in seen or href == pretty:
            continue
        seen.add(href)
        uniq.append((href, label))
    bullets = [
        f"What {title.lower()} looks like on a real work order, not a catalog page.",
        "As-found measurements before anyone resets, greases, or swaps a part.",
        "How this job hands off between millwright, electrician, and I&amp;E so the same fault is not “owned” by three crafts overnight.",
        "What belongs in the log so the next crew is not starting from a radio rumor.",
        "Where this sits on the ForgeLine ladder and which free course to take next.",
    ]
    li = "\n".join(f"      <li>{b}</li>" for b in bullets)
    who = {
        "mechanical": "Millwrights, maintenance mechanics, and rotating-equipment techs who get handed a housing, a pump, or a conveyor and are expected to make it hold.",
        "electrical": "Industrial electricians and techs who live in MCCs, VFDs, and motor leads — not residential work, not HVAC capacitor jobs.",
        "ie": "I&amp;E technicians who own loops, valves, and transmitters, and who have to defend a calibration in the control room.",
        "engineering": "Controls and reliability engineers who still have to ship something a night-shift tech can maintain.",
    }[stage]
    return f"""
    <p class="meta">{esc(STAGE_LABEL[stage])} · {access} · Plant-floor course outline</p>
    <p class="lead">{esc(desc)}</p>
    <div>
      <a class="cta" href="{player}">Open the interactive course</a>
      <a class="cta secondary" href="/catalog">Back to catalog</a>
      <a class="cta secondary" href="/paths">Learning paths</a>
    </div>
    <div class="card">
      <h2>On the job</h2>
      <p>{stage_walk(course)}</p>
      <p>{extra_topic(course)}</p>
    </div>
    <div class="card">
      <h2>What you will cover in {esc(title)}</h2>
      <p>{esc(desc)} This page is the crawlable outline Google and a curl-no-JS client can read. Quizzes, video, and progress tracking live in the course player.</p>
      <ul>
{li}
      </ul>
    </div>
    <div class="card">
      <h2>Who it is for</h2>
      <p>{who}</p>
      <p>Who it is not for: license mills, VR demos, or anyone looking for a fake testimonial. We do not invent customer quotes. Certificates of completion after quizzes go in the file. They are not a journeyman card, an ISA credential, or NFPA 70E qualification by themselves.</p>
    </div>
    <div class="card">
      <h2>Catalog facts</h2>
      <p>{catalog_blurb()}</p>
      <p>{esc(title)} is one course in that 78-course ladder. Mechanical and Electrical remain free. I&amp;E and Engineering are premium. On-site and plant cohorts are scheduled through <a href="/on-site-training">on-site training</a> or <a href="/request">plant support</a>.</p>
    </div>
    {related_html(uniq[:8])}
"""


def landing_copy(key: str) -> str:
    copies = {
        "vfd-ground-fault": """
    <p class="lead">A ground-fault trip is not an overcurrent with a different letter on the keypad. Insulation, a nicked motor lead, a wet winding, or a long cable will take a feeder if you treat GF like OC and keep resetting.</p>
    <div>
      <a class="cta" href="/courses/vfd-fundamentals-parameterization">VFD Fundamentals course</a>
      <a class="cta secondary" href="/vfd-overcurrent">Overcurrent vs ground fault</a>
      <a class="cta secondary" href="/paths/electrical">Electrical path</a>
    </div>
    <div class="card">
      <h2>What the drive is actually measuring</h2>
      <p>Variable frequency drives watch residual current on the output. When that residual is not near zero, many platforms call it a ground fault, earth fault, or GF. That is not the same analog as an overcurrent (OC / OC1 / OC2) which is looking at phase current against a limit you set — or a limit the drive derived from motor FLA. If you clear GF the same way you clear OC, you teach the night shift that the keypad is a suggestion.</p>
      <p>Typical plant sequence that burns time: pump binds, accel is too short, drive throws OC, someone lengthens accel, the next trip is GF because the motor leads were damaged when the pump was pulled last outage. Two faults, two crafts, one work order that still says “bad VFD.” The Electrical path at ForgeLine Academy starts with the difference, then parameterization for this motor, this cable, this load.</p>
      <p>Walk it in this order. Prove incoming power and grounding first. Megger the motor and the leads with the drive disconnected — a one-minute poke is not a polarization index, and a wet winding will look like a ground fault all shift. Inspect the motor cable for shield termination, damage at the gland, and length that wants a dV/dt filter. Then, and only then, open parameters. Motor data has to match the nameplate, not the last identical-looking spare.</p>
    </div>
    <div class="card">
      <h2>Plant-floor checks before you reset</h2>
      <ul>
        <li>Lockout to site procedure. Prove absence of voltage. Drives store energy.</li>
        <li>Read the fault as-found. Photograph the keypad. Do not clear it to “see if it runs.”</li>
        <li>Separate GF from OC, OV, and undervolt. They are different measurements.</li>
        <li>Disconnect motor leads at the drive and megger phase-to-ground and phase-to-phase.</li>
        <li>Check for standing water in the peckerhead, a washed-down motor, or a conduit full of coolant.</li>
        <li>Look at cable length, shield, and whether Installation &amp; Commissioning already flagged dV/dt.</li>
      </ul>
      <p>ForgeLine does not sell a 15-minute “VFD jobs near me” page. This landing exists so a search for VFD ground fault reaches a real electrician’s sequence. The free course is <a href="/courses/vfd-fundamentals-parameterization">VFD Fundamentals &amp; Parameterization</a>. Cable, EMC, and long leads are in <a href="/courses/vfd-installation-commissioning">VFD Installation &amp; Commissioning</a>. Motor insulation that keeps faking GF is in <a href="/motor-megger">motor megger and PI</a>.</p>
    </div>
    <div class="card">
      <h2>Catalog and contact</h2>
      <p>"""
        + catalog_blurb()
        + """</p>
      <p>We do not post invented customer quotes. If you want a plant class on your drive fleet, use on-site training or call. Training is not a substitute for your electrical safety program.</p>
    </div>
""",
        "vfd-overcurrent": """
    <p class="lead">Overcurrent on a VFD is usually bind, a ramp that is too proud, or motor data that does not match the nameplate. It is not a ground fault, and resetting it until the feeder opens is how plants lose a shift.</p>
    <div>
      <a class="cta" href="/courses/vfd-fundamentals-parameterization">VFD Fundamentals course</a>
      <a class="cta secondary" href="/vfd-ground-fault">Ground fault landing</a>
      <a class="cta secondary" href="/paths/electrical">Electrical path</a>
    </div>
    <div class="card">
      <h2>OC is a current limit, not a mystery</h2>
      <p>When a drive says overcurrent it is telling you phase current exceeded a threshold. That threshold might be a percentage of motor FLA you entered, a factory default that assumed a different motor, or a stall / short-ramp condition. A bound pump, a seized fan, a conveyor that is buried, or a coupling that is not turning will all look like “the VFD failed.” The millwright owns the bind. The electrician owns the measurement. Both belong on the job.</p>
      <p>Accel and decel that were copied from the last identical-looking spare are a common self-inflicted OC. So is autotune skipped because “it ran on the bench.” Parameterize this motor. Enter FLA, voltage, frequency, and the real acceleration the process can stand. If current still spikes at a consistent speed, look at mechanical resonance, belt slap, or a valve that slams shut and turns the pump into a brick.</p>
      <p>Do not confuse OC with ground fault. Residual current and phase current are different. If the last three trips flip between OC and GF, you likely have a mechanical problem and a damaged cable, not one failed inverter module. Read <a href="/vfd-ground-fault">VFD ground fault</a> next, then the free fundamentals course.</p>
    </div>
    <div class="card">
      <h2>Sequence that holds up on nights</h2>
      <ul>
        <li>As-found fault, current, speed, and whether the load is turning.</li>
        <li>Hand-rotate or millwright check for bind before you lengthen accel forever.</li>
        <li>Nameplate vs parameter motor data. Wrong FLA makes honest current look like a fault.</li>
        <li>Supply voltage and single-phasing. Garbage in still looks like OC on some platforms.</li>
        <li>Then cable and insulation — because a developing GF can ride along with OC.</li>
      </ul>
      <p>ForgeLine Academy’s Electrical path is 22 free courses, part of 44 free in a 78-course catalog. VFD Fundamentals &amp; Parameterization is the plant-floor start for OC vs GF. Installation &amp; Commissioning covers the cable and EMC that keep showing up as “random trips.” Motor starters and overloads still exist on across-the-line equipment; do not treat every motor as if it had a drive.</p>
    </div>
    <div class="card">
      <h2>Catalog and contact</h2>
      <p>"""
        + catalog_blurb()
        + """</p>
    </div>
""",
        "motor-megger": """
    <p class="lead">A one-minute poke at 500 V with wet leads is how plants fake a pass. Polarization index is a 10-minute test against a 1-minute test, written down at a voltage that matches the winding, not whatever the last tech left the dial on.</p>
    <div>
      <a class="cta" href="/courses/motor-testing-with-megger-pi">Open Motor Testing with Megger &amp; PI</a>
      <a class="cta secondary" href="/paths/electrical">Electrical path</a>
      <a class="cta secondary" href="/vfd-ground-fault">VFD ground fault</a>
    </div>
    <div class="card">
      <h2>What a real megger reading requires</h2>
      <p>Insulation resistance is not a personality test for the motor. It is a number at a stated voltage, temperature, and connection, after a discharge. 500 V, 1000 V, and 5000 V are not interchangeable. A 4160 V motor that “meggered fine at 500” was not tested. A wet peckerhead, a dirty connection, or a winding that is still hot from a run will lie. Polarization index (PI) is the 10-minute IR divided by the 1-minute IR. Guard the leads. Short the windings together for the test the procedure calls for. Discharge when you are done so the next person does not learn the hard way.</p>
      <p>The log has to hold up in a meeting. Voltage, instrument, serial if you have it, ambient, winding temperature if you have it, 1-minute, 10-minute, PI, and who ran it. “Meggered fine” is not a sentence that belongs in a CMMS. This is the first free step on the Electrical path because so many VFD ground faults and mystery trips start as insulation that nobody actually measured.</p>
      <p>ForgeLine is not an NFPA 70E credential and not a megger sales pitch. It is the plant-floor sequence industrial electricians run. Who it is for: electricians, I&amp;E, and supervisors who have to read the log. Who it is not for: residential work, HVAC, or job-listing traffic.</p>
    </div>
    <div class="card">
      <h2>When the number is not the whole job</h2>
      <ul>
        <li>Humidity and a recently washed-down motor.</li>
        <li>Leads still connected to a drive that is referencing ground differently than you think.</li>
        <li>A cable fault that looks like a winding fault until you lift the leads at both ends.</li>
        <li>A polarization index that looks heroic because the 1-minute reading was garbage.</li>
      </ul>
      <p>After the megger course, VFD Fundamentals covers how a weak winding shows up as GF. 3-phase power and motor control courses sit on the same free Electrical path. 22 free Electrical courses, 44 free overall, 78 total in the catalog.</p>
    </div>
    <div class="card">
      <h2>Catalog and contact</h2>
      <p>"""
        + catalog_blurb()
        + """</p>
    </div>
""",
        "control-valve-troubleshooting": """
    <p class="lead">If the valve will not stroke, the graphic is not evidence. Prove air, prove the 4-20 mA command, prove the stem moved. Then talk about bench set, signature, stiction, and a positioner that has been “calibrated” without as-found data.</p>
    <div>
      <a class="cta" href="/courses/control-valve-calibration-and-diagnostics">Control Valve Calibration course</a>
      <a class="cta secondary" href="/4-20ma-loop-troubleshooting">4-20 mA loops</a>
      <a class="cta secondary" href="/catalog">Catalog</a>
    </div>
    <div class="card">
      <h2>Field sequence when the valve will not stroke</h2>
      <p>Start in the field, not in the DCS. Instrument air at the positioner, not at the header two rooms away. A 3–15 psi or 6–30 psi signal that never arrives is still the most common “bad valve.” Next, the analog command at the terminals. If the loop is sitting at 3.8 mA fail-low, the valve may be doing exactly what it was told. Walk that loop — see 4-20 mA troubleshooting — before you rebuild an actuator.</p>
      <p>Once air and command are honest, watch the stem. A positioner that claims 48% with a stem that has not moved is stiction, a seized packing, a bent stem, or a feedback problem. Signature tests and HART diagnostics help after the obvious. Bench set on the bench does not prove the valve in service with process load and a sticky packing gland.</p>
      <p>Control Valve Calibration &amp; Diagnostics is a premium I&amp;E course in a catalog of 78, with 44 free Mechanical and Electrical courses below it. Smart positioners and digital feedback are a separate course. Neither one is a substitute for proving air. We do not invent plant testimonials; the procedure either works on your rack or you call and we walk it with your techs.</p>
    </div>
    <div class="card">
      <h2>What techs actually miss</h2>
      <ul>
        <li>Equalizing a DP transmitter on the same skid and thinking the valve problem is “the loop.”</li>
        <li>A bypassed interlock that lets the faceplate look in-range while the stem is pinned.</li>
        <li>Wrong cam, wrong tubing, or a positioner mounted for the opposite fail action.</li>
        <li>Calibration with no as-found / as-left, so the next outage cannot trend hysteresis.</li>
      </ul>
      <p>I&amp;E is premium. The free Electrical and Mechanical paths still matter: a bound actuator is mechanical; a dead 24 V supply is electrical. Use the landings and the catalog together.</p>
    </div>
    <div class="card">
      <h2>Catalog and contact</h2>
      <p>"""
        + catalog_blurb()
        + """</p>
    </div>
""",
        "4-20ma-loop-troubleshooting": """
    <p class="lead">A DCS point at 52% is not a measurement until a meter in the loop agrees. 3.8 mA fail-low, a missing 24 V supply, reversed polarity, and a HART communicator that is talking past a broken analog still get written up as “bad transmitter.”</p>
    <div>
      <a class="cta" href="/courses/hart-transmitters-and-smart-instrumentation">HART Transmitters course</a>
      <a class="cta secondary" href="/control-valve-troubleshooting">Control valves</a>
      <a class="cta secondary" href="/ie-technician">I&amp;E technician</a>
    </div>
    <div class="card">
      <h2>Walk the loop</h2>
      <p>Put a meter in series. Confirm loop current, not just a graphic. Measure supply at the transmitter, not only at the cabinet. Add up loop resistance: barriers, long runs, indicators, and a HART resistor that someone shorted. If current is sitting at 3.8 mA, look at fail-safe configuration before you pull the sensor. If current is 0 mA, you have an open, a dead supply, or a transmitter that is off. If current is pegged, look at a shorted pair or a transmitter that has been forced.</p>
      <p>HART rides on the analog. A communicator can look healthy while the analog into the DCS is wrong — or the analog can be right while the digital diagnostics are screaming. Pressure, temperature, flow, and level transmitters all share this loop physics. Impulse lines, thermowells, and primary elements are process problems that mimic electronics. The I&amp;E courses in the catalog separate those on purpose: HART and smart instrumentation, pressure transmitters, temperature, flow, and level each get their own treatment.</p>
      <p>This landing is for searchers who typed “4-20 mA loop troubleshooting” and would otherwise land on a JavaScript shell. The interactive lessons are in the premium I&amp;E courses. Mechanical millwrights still own plugged taps. Electricians still own the 24 V and the grounding. The loop is a three-craft job whether the org chart says so or not.</p>
    </div>
    <div class="card">
      <h2>Checks that belong in the book</h2>
      <ul>
        <li>Supply voltage under load at the transmitter.</li>
        <li>Series current vs DCS engineering units.</li>
        <li>Polarity and shield at one end only, per your spec.</li>
        <li>Fail-low / fail-high configuration vs the actual 3.8 or 20.5 mA.</li>
        <li>HART vs analog disagreement before you condemn the sensor.</li>
      </ul>
      <p>"""
        + catalog_blurb()
        + """</p>
    </div>
""",
        "paths-mechanical": """
    <p class="lead">The Mechanical path is 22 free millwright courses. It starts with bearings, lubrication, and shaft alignment — the jobs that still get written up as “replace the bearing” when the steel is trying to tell you something else.</p>
    <div>
      <a class="cta" href="/courses/bearings-lubrication-alignment-fundamentals">Start with bearings</a>
      <a class="cta secondary" href="/paths">All paths</a>
      <a class="cta secondary" href="/catalog">Full catalog</a>
    </div>
    <div class="card">
      <h2>What the Mechanical path is</h2>
      <p>ForgeLine Academy’s catalog is 78 courses. 44 are free: 22 Mechanical and 22 Electrical. Premium is I&amp;E and Engineering. The Mechanical path is the millwright ladder: bearings and alignment, pumps and mechanical seals, conveyors, gearboxes, couplings, fans, hydraulics, vibration, thermography, ultrasound lubrication, rigging, machine guarding, precision maintenance, and rotating-equipment reliability. It is not a four-hour overview of the plant and it is not 22 courses pretending to be the whole academy.</p>
      <p>First course: Bearings, Lubrication &amp; Alignment Fundamentals. Most bearing failures on the plant floor are lubrication or alignment. The procedure happens before anyone pulls a housing. From there, pumps and seals, conveyors and drives, measurement, and the predictive tools (vibration, IR, ultrasound) that keep you from living in breakdown.</p>
      <p>This dedicated landing exists because /paths is a JavaScript app. Search and curl-no-JS get this HTML: unique title, this H1, and the actual path description. Interactive progress still lives in the app once you sign in. We do not invent testimonials. We do not promise a license. Certificates of completion after quizzes go in the file.</p>
    </div>
    <div class="card">
      <h2>Where to go next</h2>
      <ul>
        <li><a href="/courses/bearings-lubrication-alignment-fundamentals">Bearings, Lubrication &amp; Alignment Fundamentals</a> — free start.</li>
        <li><a href="/courses/pump-and-mechanical-seal-maintenance">Pump &amp; Mechanical Seal Maintenance</a></li>
        <li><a href="/courses/precision-measurement-and-troubleshooting">Precision Measurement &amp; Troubleshooting</a></li>
        <li><a href="/paths/electrical">Electrical path</a> if the fault is actually in the MCC.</li>
        <li><a href="/on-site-training">On-site millwright training</a> for plant cohorts.</li>
      </ul>
      <p>"""
        + catalog_blurb()
        + """</p>
    </div>
""",
        "paths-electrical": """
    <p class="lead">The Electrical path is 22 free industrial electrician courses: megger and PI, VFD ground fault versus overcurrent, motor control, prints, 3-phase power, starters, and the safety program that is supposed to exist before anyone opens a bucket.</p>
    <div>
      <a class="cta" href="/courses/motor-testing-with-megger-pi">Start with motor megger</a>
      <a class="cta secondary" href="/courses/vfd-fundamentals-parameterization">VFD fundamentals</a>
      <a class="cta secondary" href="/paths">All paths</a>
    </div>
    <div class="card">
      <h2>What the Electrical path is</h2>
      <p>44 free courses in a 78-course catalog. Electrical is the other free half. It is built for plant electricians, not residential and not “VFD jobs near me.” First lessons that search actually cares about: Motor Testing with Megger &amp; PI, VFD Fundamentals &amp; Parameterization, motor starters and chattering coils, industrial motor control circuits, electrical prints, and 3-phase power. Then installation, protection, grounding, panels, hazardous locations, power quality, and commissioning.</p>
      <p>Dedicated landings hang off this path so a crawler does not have to execute JavaScript to read a sentence: <a href="/motor-megger">motor megger</a>, <a href="/vfd-ground-fault">VFD ground fault</a>, <a href="/vfd-overcurrent">VFD overcurrent</a>. The interactive player is still in the app. This page is the outline you can curl.</p>
      <p>I&amp;E (valves, 4-20 mA, HART) is premium and sits on top of this path on purpose. If the loop is dead because 24 V is dead, that is still an electrician’s job. If the valve will not stroke with a good signal, that is I&amp;E. The catalog is honest about the split.</p>
    </div>
    <div class="card">
      <h2>Where to go next</h2>
      <ul>
        <li><a href="/courses/motor-testing-with-megger-pi">Motor Testing with Megger &amp; PI</a></li>
        <li><a href="/courses/vfd-fundamentals-parameterization">VFD Fundamentals &amp; Parameterization</a></li>
        <li><a href="/courses/industrial-motor-control-circuits">Industrial Motor Control Circuits</a></li>
        <li><a href="/motor-control-training">Motor control training landing</a></li>
        <li><a href="/paths/mechanical">Mechanical path</a> when the motor is fine and the pump is not.</li>
      </ul>
      <p>"""
        + catalog_blurb()
        + """</p>
    </div>
""",
    }
    return copies[key]


def word_count(html: str) -> int:
    text = re.sub(r"<script[\s\S]*?</script>", " ", html, flags=re.I)
    text = re.sub(r"<style[\s\S]*?</style>", " ", text, flags=re.I)
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"&[a-z]+;", " ", text)
    words = re.findall(r"[A-Za-z0-9][A-Za-z0-9'’.-]*", text)
    return len(words)


def write_html(rel_dir: str, content: str) -> Path:
    dest = PUBLIC / rel_dir
    dest.mkdir(parents=True, exist_ok=True)
    path = dest / "index.html"
    path.write_text(content, encoding="utf-8")
    return path


def redirects(courses: list[dict]) -> str:
    lines = [
        "# Static robots.txt and sitemap.xml are served from /public (do not self-rewrite; that 500s on some edges).",
        "# Specific static HTML must win before the SPA splat. On Netlify/Bolt, files usually win if they exist;",
        "# explicit 200s keep crawlers off the homepage shell.",
        "",
        "/pricing              /pricing/index.html          200",
        "/pricing/             /pricing/index.html          200",
        "/on-site-training     /on-site-training/index.html 200",
        "/on-site-training/    /on-site-training/index.html 200",
        "/vfd-troubleshooting  /vfd-troubleshooting/index.html 200",
        "/vfd-troubleshooting/ /vfd-troubleshooting/index.html 200",
        "/motor-control-training /motor-control-training/index.html 200",
        "/motor-control-training/ /motor-control-training/index.html 200",
        "/ie-technician        /ie-technician/index.html    200",
        "/ie-technician/       /ie-technician/index.html    200",
        "/plants               /plants/index.html           200",
        "/plants/              /plants/index.html           200",
        "/services             /services/index.html         200",
        "/services/            /services/index.html         200",
        "",
        "/vfd-ground-fault     /vfd-ground-fault/index.html 200",
        "/vfd-ground-fault/    /vfd-ground-fault/index.html 200",
        "/vfd-overcurrent      /vfd-overcurrent/index.html 200",
        "/vfd-overcurrent/     /vfd-overcurrent/index.html 200",
        "/motor-megger         /motor-megger/index.html 200",
        "/motor-megger/        /motor-megger/index.html 200",
        "/control-valve-troubleshooting /control-valve-troubleshooting/index.html 200",
        "/control-valve-troubleshooting/ /control-valve-troubleshooting/index.html 200",
        "/4-20ma-loop-troubleshooting /4-20ma-loop-troubleshooting/index.html 200",
        "/4-20ma-loop-troubleshooting/ /4-20ma-loop-troubleshooting/index.html 200",
        "/paths/mechanical     /paths/mechanical/index.html 200",
        "/paths/mechanical/    /paths/mechanical/index.html 200",
        "/paths/electrical     /paths/electrical/index.html 200",
        "/paths/electrical/    /paths/electrical/index.html 200",
        "",
        "/courses/:slug        /courses/:slug/index.html 200",
        "/courses/:slug/       /courses/:slug/index.html 200",
        "",
        "/*                    /index.html                  200",
        "",
    ]
    return "\n".join(lines)


def sitemap_xml(courses: list[dict]) -> str:
    urls = [
        "/",
        "/catalog",
        "/paths",
        "/upgrade",
        "/book",
        "/request",
    ]
    urls += [f"/courses/{c['slug']}" for c in courses]
    urls += [L["path"] for L in LANDINGS]
    extra = [
        "/on-site-training",
        "/vfd-troubleshooting",
        "/motor-control-training",
        "/ie-technician",
        "/plants",
        "/services",
        "/pricing",
    ]
    for u in extra:
        if u not in urls:
            urls.append(u)
    seen = set()
    ordered = []
    for u in urls:
        if u not in seen:
            seen.add(u)
            ordered.append(u)
    parts = ['<?xml version="1.0" encoding="UTF-8"?>', '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
    for u in ordered:
        loc = SITE if u == "/" else f"{SITE}{u}"
        parts.append("  <url>")
        parts.append(f"    <loc>{loc}</loc>")
        parts.append(f"    <lastmod>{LASTMOD}</lastmod>")
        parts.append("    <changefreq>weekly</changefreq>")
        parts.append("  </url>")
    parts.append("</urlset>")
    parts.append("")
    return "\n".join(parts)


def pad_if_needed(html: str, extra_paragraph: str) -> str:
    if word_count(html) >= 300:
        return html
    needle = '<p class="note">'
    card = f'<div class="card"><h2>More plant-floor context</h2><p>{extra_paragraph}</p></div>\n    '
    if needle in html:
        return html.replace(needle, card + needle, 1)
    return html


def main() -> None:
    courses = parse_courses()
    reports = []

    for course in courses:
        canonical = f"{SITE}/courses/{course['slug']}"
        title = f"{course['title']} — {ORG}"
        desc = clip(course["description"])
        body = course_body(course, courses)
        page = html_page(
            title,
            desc,
            canonical,
            course["title"],
            body,
            [org_ld(), course_ld(course["title"], course["description"], canonical, course["tier"] == "free")],
        )
        page = pad_if_needed(
            page,
            f"{esc(course['title'])} belongs on the {esc(STAGE_LABEL[course['stage']])} at {ORG}. "
            "Run the as-found, write the log, and use the interactive player for quizzes and progress. "
            f"The catalog is 78 courses with 44 free. Contact {PHONE} or {EMAIL} for plant cohorts.",
        )
        path = write_html(f"courses/{course['slug']}", page)
        wc = word_count(page)
        if wc < 300:
            raise SystemExit(f"course {course['slug']} only {wc} words")
        reports.append((str(path.relative_to(ROOT)), wc, title))

    extra_pad = (
        f"{ORG} trains millwrights, industrial electricians, and I&amp;E techs on the plant floor. "
        "44 free courses (Mechanical + Electrical) and 78 total including premium I&amp;E and Engineering. "
        f"Phone {PHONE}. Email {EMAIL}. Training does not replace site LOTO."
    )
    for L in LANDINGS:
        canonical = f"{SITE}{L['path']}"
        body = landing_copy(L["slug"]) + related_html(L["related"])
        # landings: Course JSON-LD for the primary related course plus Organization
        primary_href = L["related"][0][0]
        primary_name = L["related"][0][1]
        ld = [org_ld(), course_ld(primary_name, L["description"], canonical, True)]
        page = html_page(L["title"], L["description"], canonical, L["h1"], body, ld)
        page = pad_if_needed(page, extra_pad)
        rel = L["path"].lstrip("/")
        path = write_html(rel, page)
        wc = word_count(page)
        if wc < 300:
            raise SystemExit(f"landing {L['path']} only {wc} words")
        reports.append((str(path.relative_to(ROOT)), wc, L["title"]))

    (PUBLIC / "_redirects").write_text(redirects(courses), encoding="utf-8")
    (PUBLIC / "sitemap.xml").write_text(sitemap_xml(courses), encoding="utf-8")

    # Keep committed dist in sync for hosts that serve dist/ as-is.
    dist = ROOT / "dist"
    if dist.is_dir():
        import shutil

        for src in reports:
            rel = Path(src[0]).relative_to("public") if str(src[0]).startswith("public/") else Path(src[0])
            # reports paths are public/...
        for item in ["_redirects", "sitemap.xml"]:
            shutil.copy2(PUBLIC / item, dist / item)
        # copy generated trees
        for folder in ["courses", "vfd-ground-fault", "vfd-overcurrent", "motor-megger",
                       "control-valve-troubleshooting", "4-20ma-loop-troubleshooting", "paths",
                       "on-site-training", "vfd-troubleshooting", "motor-control-training",
                       "ie-technician", "plants", "pricing", "services"]:
            src = PUBLIC / folder
            if not src.exists():
                continue
            dest = dist / folder
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(src, dest)

    print(f"generated {len(reports)} html pages")
    for rel, wc, title in reports[:5]:
        print(f"  {wc:4d}  {rel}  {title[:60]}")
    print("  ...")
    for rel, wc, title in reports[-7:]:
        print(f"  {wc:4d}  {rel}  {title[:60]}")


if __name__ == "__main__":
    main()
