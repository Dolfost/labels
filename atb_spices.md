# ATB spices

Spices bought at ATB (atbmarket.com). Snapshot of the product pages taken on
2026-10-24; prices change, the links and product codes are the stable part.

| # | Product (as listed) | English | Brand | Net | Price | Code | Link |
|---|---------------------|---------|-------|-----|-------|------|------|
| 1 | Приправа Суміш перців мелена | Ground pepper mix | Своя Лінія | 30 g | 28.50 ₴ | 134379 | [open](https://www.atbmarket.com/product/priprava-30g-svoa-linia-sumis-perciv-melena) |
| 2 | Перець червоний мелений паприка | Paprika, ground | Своя Лінія | 30 g | 16.90 ₴ | 163949 | [open](https://www.atbmarket.com/product/perec-30-g-svoa-linia-cervonij-melenij-paprika) |
| 3 | Базилік сушений подрібнений | Basil, dried, crushed | Своя Лінія | 15 g | 12.90 ₴ | 149936 | [open](https://www.atbmarket.com/product/bazilik-15g-svoa-linia-susenij-podribnenij) |
| 4 | Перець чорний мелений | Black pepper, ground | Розумний Вибір | 60 g | 45.90 ₴ | 151072 | [open](https://www.atbmarket.com/product/perec-cornij-60g-rozumnij-vibir-melenij) |
| 5 | Коріандр мелений | Coriander, ground | Своя Лінія | 40 g | 13.90 ₴ | 149113 | [open](https://www.atbmarket.com/product/koriandr-40g-svoa-linia-melenij) |
| 6 | Імбир мелений | Ginger, ground | Своя Лінія | 40 g | 13.50 ₴ (sale price) | 149937 | [open](https://www.atbmarket.com/product/imbir-40g-svoa-linia-melenij) |

Notes

- None of the six pages list a composition (склад). The pepper mix ratio
  below was copied from the packet, not from the site. "Країна: Україна" on the pages is the packer's
  country, not where the spice was grown.
- All six are filed under "Призначення: Універсальні" (all-purpose seasoning).
- The ginger page is the only one with nutrition data: 1791 kJ/100 g,
  carbohydrates 88.1 g, protein 2 g, fat 2 g per 100 g.
- The basil link originally carried a `?query=...` search parameter; it is
  stripped above and below, which also keeps the QR code smaller.

## Ready for spices.toml

Ukrainian name on the front, form of the spice as the subtitle, shop and brand
as the source line (no weight: the spices are re-bottled), ATB page as the QR
target. This is what spices.toml currently contains.

```toml
[[spice]]
name = "Суміш перців"
subtitle = "мелена"
contents = { "перець чорний" = "49 %", "перець духмяний" = "15 %", "перець червоний" = "15 %", "паприка червона" = "10 %", "паприка зелена" = "9 %", "перець білий" = "2 %" }

source = "АТБ · Своя Лінія"
url = "https://www.atbmarket.com/product/priprava-30g-svoa-linia-sumis-perciv-melena"

[[spice]]
name = "Паприка"
subtitle = "перець червоний мелений"
source = "АТБ · Своя Лінія"
url = "https://www.atbmarket.com/product/perec-30-g-svoa-linia-cervonij-melenij-paprika"

[[spice]]
name = "Базилік"
subtitle = "сушений, подрібнений"
source = "АТБ · Своя Лінія"
url = "https://www.atbmarket.com/product/bazilik-15g-svoa-linia-susenij-podribnenij"

[[spice]]
name = "Перець чорний"
subtitle = "мелений"
source = "АТБ · Розумний Вибір"
url = "https://www.atbmarket.com/product/perec-cornij-60g-rozumnij-vibir-melenij"

[[spice]]
name = "Коріандр"
subtitle = "мелений"
source = "АТБ · Своя Лінія"
url = "https://www.atbmarket.com/product/koriandr-40g-svoa-linia-melenij"

[[spice]]
name = "Імбир"
subtitle = "мелений"
source = "АТБ · Своя Лінія"
url = "https://www.atbmarket.com/product/imbir-40g-svoa-linia-melenij"
```
