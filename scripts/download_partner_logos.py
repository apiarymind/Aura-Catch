import os
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup

# Lista domen partnerów Aura Catch
PARTNERS = [
    "https://www.dhgate.com",
    "https://www.clickandgrow.com",
    "https://corneacare.com",
    "https://fabfinds.co.uk",
    "https://www.garvee.com",
    "https://www.goldentree.shop",
    "https://heivy.com",
    "https://www.herbspro.com",
    "https://www.karaca.com",
    "https://www.kitchenshop.eu",
    "https://www.notino.com",
    "https://www.onebioshop.com",
    "https://www.parallels.com",
    "https://www.plessers.com",
    "https://www.qathu.com",
    "https://www.stylevana.com",
    "https://www.tenergy.com",
    "https://www.vevor.com",
]

# Tworzymy folder docelowy, jeśli nie istnieje
OUTPUT_DIR = "assets/logos"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Udajemy normalną przeglądarkę, żeby nas nie zablokowali
HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    )
}

FALLBACK_PROVIDERS = [
    lambda domain: f"https://logo.clearbit.com/{domain}",
    lambda domain: f"https://icon.horse/icon/{domain}",
    lambda domain: f"https://www.google.com/s2/favicons?sz=256&domain_url={domain}",
]


def _guess_extension(content_type: str, logo_url: str) -> str:
    ext = os.path.splitext(urlparse(logo_url).path)[1].lower()
    if ext in {".png", ".jpg", ".jpeg", ".svg", ".webp", ".ico"}:
        return ".jpg" if ext == ".jpeg" else ext

    content_type = (content_type or "").lower()
    if "svg" in content_type:
        return ".svg"
    if "webp" in content_type:
        return ".webp"
    if "jpeg" in content_type or "jpg" in content_type:
        return ".jpg"
    if "x-icon" in content_type or "icon" in content_type:
        return ".ico"
    return ".png"


def _save_logo_from_url(logo_url: str, domain: str) -> str:
    img_response = requests.get(logo_url, headers=HEADERS, timeout=15)
    img_response.raise_for_status()

    ext = _guess_extension(img_response.headers.get("Content-Type", ""), logo_url)
    short_name = domain.split(".")[0]
    filename = os.path.join(OUTPUT_DIR, f"{short_name}{ext}")

    with open(filename, "wb") as f:
        f.write(img_response.content)

    return filename


def _find_logo_url(base_url: str, soup: BeautifulSoup) -> str | None:
    # 1) Najpierw próbujemy stricte obrazki z "logo" w atrybutach
    for img in soup.find_all("img"):
        src = (img.get("src") or "").lower()
        alt = (img.get("alt") or "").lower()
        classes = " ".join(img.get("class", [])).lower()
        img_id = (img.get("id") or "").lower()

        if "logo" in src or "logo" in alt or "logo" in classes or "logo" in img_id:
            logo_url = img.get("src")
            if not logo_url or logo_url.startswith("data:image"):
                logo_url = img.get("data-src") or img.get("data-lazy-src") or logo_url
            if logo_url:
                return urljoin(base_url, logo_url)

    # 2) Potem link rel=icon / shortcut icon / apple-touch-icon
    for rel_name in ("icon", "shortcut icon", "apple-touch-icon"):
        tag = soup.find("link", rel=lambda v: v and rel_name in " ".join(v).lower())
        if tag and tag.get("href"):
            return urljoin(base_url, tag["href"])

    # 3) Meta og:image jako ostateczny fallback
    og = soup.find("meta", property="og:image") or soup.find("meta", attrs={"name": "og:image"})
    if og and og.get("content"):
        return urljoin(base_url, og["content"])

    return None


def download_logo(url: str) -> None:
    domain = urlparse(url).netloc.replace("www.", "")
    short_name = domain.split(".")[0]

    try:
        print(f"Skanuję: {domain}...")
        response = requests.get(url, headers=HEADERS, timeout=15)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, "html.parser")
        logo_url = _find_logo_url(url, soup)

        if not logo_url:
            print(f"[BŁĄD] Nie znaleziono jednoznacznego tagu z logo na {domain}.")
            raise RuntimeError("logo_not_found_in_html")

        filename = _save_logo_from_url(logo_url, domain)
        print(f"[SUKCES] Zapisano logo: {filename}")
    except Exception as e:
        print(f"[WARN] Główne pobranie nieudane dla {domain}: {e}")
        for provider in FALLBACK_PROVIDERS:
            fallback_url = provider(domain)
            try:
                filename = _save_logo_from_url(fallback_url, domain)
                print(f"[SUKCES] Fallback zapisano: {filename}")
                return
            except Exception:
                continue

        print(f"[BŁĄD] Nie udało się pobrać logo dla {domain} z żadnego fallbacku.")


if __name__ == "__main__":
    for partner in PARTNERS:
        download_logo(partner)

    print("\nKoniec roboty. Sprawdź folder assets/logos!")
