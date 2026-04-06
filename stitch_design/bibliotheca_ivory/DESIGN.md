# Design System: The Tactile Archive

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Digital Sanctuary."** Unlike standard utility apps that prioritize rapid-fire micro-interactions, this system is designed for "Deep Interface"—a state where the UI recedes to allow the literature to take center stage. 

We break the "template" look through **Editorial Asymmetry**. By utilizing generous, intentional whitespace and overlapping elements (such as book covers bleeding slightly over container edges), we evoke the feeling of a physical desk covered in high-quality stationery. This is a "Bookshelf-chic" aesthetic that rejects the rigid, boxy constraints of traditional Material Design in favor of a fluid, layered, and tactile experience.

---

## 2. Colors & Materiality
The palette is rooted in the "Paper & Ink" philosophy. We avoid pure blacks and harsh whites to reduce eye strain during long reading sessions.

### The "No-Line" Rule
**Prohibit 1px solid borders for sectioning.** Physical books do not have outlines; they have edges. Boundaries must be defined solely through background color shifts. For example, a `surface-container-low` section should sit on a `surface` background to create a "well" effect without a single line being drawn.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of fine vellum.
*   **Base:** `surface` (#faf9f5) - The master background.
*   **The "Sheet":** `surface-container-lowest` (#ffffff) - Used for primary content cards or the main reading pane to provide maximum contrast.
*   **The "Tray":** `surface-container` (#eeeeea) - Used for grouping secondary controls or navigation sidebars.

### Glass & Gradient Rule
To move beyond a "flat" digital feel, use **Glassmorphism** for floating headers or navigation bars. Use `surface` at 85% opacity with a `20px` backdrop-blur. 
*   **Signature Texture:** For primary CTAs (e.g., "Start Reading"), use a subtle linear gradient from `primary` (#061b0e) to `primary-container` (#1b3022). This adds a "silk-bound book" depth to the button.

---

## 3. Typography: The Editorial Voice
Our typography pairing is a dialogue between the timelessness of the printed word and the precision of modern interface design.

*   **The Voice (Noto Serif):** Used for `display` and `headline` scales. This represents the "Soul" of the library. It is used for book titles, author names, and editorial headers.
*   **The Engine (Manrope):** Used for `title`, `body`, and `label` scales. This is a high-legibility sans-serif that handles the functional UI—navigation, metadata, and buttons.

**Scale Highlight:** 
*   **Display-LG (3.5rem):** Set with a negative letter-spacing (-0.02em) to create a tight, high-end magazine masthead feel.
*   **Body-LG (1rem):** Increased line-height (1.6) to ensure the "Bookshelf-chic" focus on readability is maintained.

---

## 4. Elevation & Depth
Traditional drop shadows are too aggressive for a "Sanctuary." We use **Tonal Layering** and **Ambient Shadows**.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` section. The delta in color provides enough "lift" to the eye without the clutter of a shadow.
*   **Ambient Shadows:** For floating elements like a "Currently Reading" mini-player, use a shadow with a `32px` blur, 0px offset, and 6% opacity of `on-surface` (#1a1c1a). 
*   **The "Ghost Border":** If accessibility requires a container definition (e.g., in Dark Mode), use `outline-variant` at **15% opacity**. Never use 100% opaque borders.

---

## 5. Components

### Buttons
*   **Primary:** High-gloss `primary` (#061b0e) with `on-primary` text. Shape: `lg` (1rem) rounding. No shadow; use a 1px "inner glow" using a lighter version of the primary color to simulate a beveled edge.
*   **Tertiary:** Only `on-surface` text with no container. On hover, a `surface-container-high` background fades in at 50% opacity.

### Cards & Lists
*   **The "No Divider" Mandate:** Forbid the use of divider lines. Separate list items using the **Spacing Scale** (e.g., 1.5rem vertical gaps) or subtle background alternates using `surface-container-low`.
*   **Book Cards:** Book covers should have a `sm` (0.25rem) corner radius and a `1px` inner-stroke of `outline-variant` at 20% to simulate the "cut" of a book board.

### Input Fields
*   **Style:** Minimalist. No bottom line or box. Use a `surface-container-highest` background with `xl` (1.5rem) rounding for search bars to make them feel organic and "held."

### Progress Indicators (Reading Progress)
*   **Tactile Bar:** Instead of a thin line, use a thick `primary-fixed` bar with the `primary` color filling it. The edges should be `full` rounded to feel like a bookmark.

---

## 6. Do’s and Don’ts

### Do
*   **Do** use asymmetrical layouts. A book cover can be centered while the text description is left-aligned with a wide margin to create "breathing room."
*   **Do** use the `tertiary` (#271013) palette for "Human" elements, such as personal notes, highlights, or "Staff Picks."
*   **Do** prioritize the "Paper" background. If a screen feels too busy, remove a container, don't add a border.

### Don't
*   **Don't** use pure black (#000000). Use `primary` (#061b0e) or `on-surface` (#1a1c1a) for all text to keep the "ink on paper" feel.
*   **Don't** use "Snappy" animations. Use ease-in-out durations (300ms+) that mimic the weight and resistance of turning a physical page.
*   **Don't** use standard Material icons. Use thin-stroke (1px or 1.5px) icons to match the sophistication of the Noto Serif typeface.