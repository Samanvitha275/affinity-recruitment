#!/usr/bin/env python3
"""
Question 1: MDComputers Product Scraper
Extract product information from mdcomputers.in search results
"""

import argparse
import json
import sys
from urllib.parse import urlencode, urljoin

import requests
from bs4 import BeautifulSoup

BASE_URL = "https://mdcomputers.in"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
}


def fetch_search_page(search_term: str, page: int = 1) -> str:
    """Fetch search results page and return HTML"""
    params = {
        "route": "product/search",
        "search": search_term
    }
    if page > 1:
        params["page"] = page
    
    url = f"{BASE_URL}/?{urlencode(params)}"
    print(f"Fetching page {page}: {url}")
    
    try:
        response = requests.get(url, headers=HEADERS, timeout=15)
        response.raise_for_status()
        return response.text
    except requests.RequestException as e:
        print(f"Error fetching page: {e}", file=sys.stderr)
        raise


def parse_products(html: str) -> list:
    """Parse HTML and extract product information"""
    soup = BeautifulSoup(html, "html.parser")
    products = []
    seen_urls = set()
    
    # Find all product containers (try multiple possible class names)
    product_cards = soup.find_all("div", class_="product-thumb")
    if not product_cards:
        product_cards = soup.find_all("div", class_="product-layout")
    
    for card in product_cards:
        try:
            # Extract product name and URL
            name_tag = card.find("h4")
            if not name_tag:
                name_tag = card.find("a", class_="name")
            
            if not name_tag:
                continue
            
            # Get link element
            link = name_tag.find("a") if name_tag.name != "a" else name_tag
            if not link:
                continue
            
            name = link.get_text(strip=True)
            product_url = urljoin(BASE_URL, link.get("href", ""))
            
            # Avoid duplicates across pages
            if product_url in seen_urls or not name:
                continue
            seen_urls.add(product_url)
            
            # Extract price (try multiple selectors)
            price_tag = card.find("span", class_="price-new")
            if not price_tag:
                price_tag = card.find("span", class_="price")
            if not price_tag:
                price_tag = card.find("p", class_="price")
            
            price = price_tag.get_text(strip=True) if price_tag else "N/A"
            
            # Extract stock status
            stock_tag = card.find("span", class_="stock")
            stock = stock_tag.get_text(strip=True) if stock_tag else "N/A"
            
            product = {
                "name": name,
                "price": price,
                "stock": stock,
                "url": product_url
            }
            products.append(product)
            
        except Exception as e:
            print(f"Warning: Error parsing product: {e}", file=sys.stderr)
            continue
    
    return products


def display_table(products):
    """Display products in formatted table"""
    if not products:
        print("No products found.")
        return
    
    print(f"\nFound {len(products)} product(s):\n")
    print("-" * 100)
    for i, p in enumerate(products, 1):
        print(f"\n{i}. {p['name']}")
        print(f"   Price: {p['price']}")
        print(f"   Stock: {p['stock']}")
        print(f"   Link:  {p['url']}")
    print("\n" + "-" * 100)


def main():
    parser = argparse.ArgumentParser(
        description="Extract products from mdcomputers.in"
    )
    parser.add_argument("search_term", help='Search term (e.g., "external hard drive")')
    parser.add_argument("--pages", type=int, default=1, help="Number of pages to fetch")
    parser.add_argument("--format", choices=["table", "json"], default="table")
    parser.add_argument("--debug", action="store_true", help="Save raw HTML to debug_page.html")
    
    args = parser.parse_args()
    
    try:
        html = fetch_search_page(args.search_term, page=1)
    except Exception as e:
        sys.exit(1)
    
    if args.debug:
        with open("debug_page.html", "w", encoding="utf-8") as f:
            f.write(html)
        print("✓ HTML saved to debug_page.html - inspect to verify CSS selectors")
        return
    
    all_products = parse_products(html)
    
    # Fetch additional pages if requested
    for page in range(2, args.pages + 1):
        try:
            html = fetch_search_page(args.search_term, page=page)
            page_products = parse_products(html)
            if not page_products:
                break
            all_products.extend(page_products)
        except Exception as e:
            print(f"Warning: Could not fetch page {page}, stopping here", file=sys.stderr)
            break
    
    if args.format == "json":
        print(json.dumps(all_products, indent=2, ensure_ascii=False))
    else:
        display_table(all_products)


if __name__ == "__main__":
    main()