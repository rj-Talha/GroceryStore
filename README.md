# daana

Flutter implementation of the **Daana** grocery app design — a premium-minimal
pantry for Pakistan with AI recipes, AI ingredient finder, and bilingual (EN/UR)
voice ordering.

The HTML/CSS prototypes from Claude Design (in `_design/`) are reproduced
pixel-fairly in Flutter, mobile-first.

## Implemented screens

| Tab        | File                                         | Notes                          |
|------------|----------------------------------------------|--------------------------------|
| Home       | `lib/screens/home_screen.dart`               | Hero, categories, recommendations, AI tile, mango list |
| Recipes    | `lib/screens/ai_recipe_screen.dart`          | Type ingredients → 3 ranked recipes with have/need split |
| Cook       | `lib/screens/ai_ingredient_screen.dart`      | Dish → priced ingredient table with serving stepper |
| Cart       | `lib/screens/cart_screen.dart`               | Qty controls, totals, payment options |
| —          | `lib/screens/search_screen.dart`             | Reached from home search                |
| —          | `lib/screens/product_detail_screen.dart`     | Reached from any product card           |
| —          | `lib/screens/voice_modal.dart`               | Triggered from the mic button (EN/UR)   |

## Design system

`lib/theme/tokens.dart` — colors (`bg #F6F3EC`, `ink #1A1814`, `moss #3D5A3A`),
fonts (Instrument Serif / Inter / Noto Nastaliq Urdu, loaded via `google_fonts`).

`lib/widgets/` — `DaanaIcon` (custom SVG-path icons), `ProductPlaceholder`
(striped placeholder per design principle "no AI-drawn produce"), `Btn`, `DChip`,
`Eyebrow`, `PriceText`, `ProductCard`.

## Run

```
flutter pub get
flutter run                # picks an attached device
flutter run -d windows     # desktop
flutter run -d chrome      # web (requires `flutter create . --platforms web` first)
```

First run downloads Google Fonts at runtime; subsequent runs use cached fonts.
