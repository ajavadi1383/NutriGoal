# NutriGoal Design Guide

*Version 1.0 • Updated December 2024*

---

## 🎨 Overview

This design guide establishes the visual language and design principles for the NutriGoal iOS app. Our design system prioritizes **clarity**, **accessibility**, and **emotional connection** to create a guilt-free nutrition tracking experience.

---

## 🎯 Design Principles

### 1. **Clarity First**
- Clean, uncluttered interfaces
- Clear information hierarchy
- Readable typography at all sizes

### 2. **Guilt-Free Experience**
- Positive, encouraging visual language
- Warm, approachable color palette
- Smooth, delightful interactions

### 3. **Accessible by Default**
- WCAG 2.1 AA compliance
- High contrast ratios
- Scalable text and touch targets

### 4. **Consistent & Cohesive**
- Unified design system across all screens
- Predictable interaction patterns
- Seamless user experience

---

## 🎨 Color System

Our color palette is built around wellness, trust, and positivity.

### Primary Colors

```swift
NGColor.primary   = #3D8BFF  // Trustworthy blue
NGColor.secondary = #FFB74D  // Warm orange
```

**Primary Blue (#3D8BFF)**
- Usage: CTA buttons, links, active states
- Personality: Trustworthy, professional, calming
- Accessibility: AA compliant on white

**Secondary Orange (#FFB74D)**
- Usage: Highlights, success states, gradients
- Personality: Warm, encouraging, energetic
- Accessibility: AA compliant on white

### Semantic Colors

```swift
NGColor.success = #4CAF50   // Green for positive feedback
NGColor.warning = #FF9800   // Orange for caution
NGColor.error   = #F44336   // Red for errors
```

### Grayscale System

```swift
NGColor.gray1 = #F8F9FA  // Background surfaces
NGColor.gray2 = #E9ECEF  // Borders, dividers
NGColor.gray3 = #DEE2E6  // Disabled states
NGColor.gray4 = #CED4DA  // Placeholder text
NGColor.gray5 = #6C757D  // Secondary text
NGColor.gray6 = #495057  // Primary text
```

### Usage Guidelines

- **Primary**: Use sparingly for key actions and navigation
- **Secondary**: Use for highlights and positive feedback
- **Grayscale**: Use for text, backgrounds, and supporting elements
- **Semantic**: Use only for their intended meanings (success/warning/error)

---

## ✍️ Typography

### Font Stack
- **System Font**: San Francisco (iOS default)
- **Fallback**: System UI fonts

### Type Scale

```swift
// Titles
NGFont.titleXL = 32pt, Bold     // Hero headlines
NGFont.titleL  = 28pt, Bold     // Page titles
NGFont.titleM  = 24pt, Semibold // Section headers
NGFont.titleS  = 20pt, Semibold // Card titles

// Body Text
NGFont.bodyL   = 18pt, Regular  // Large body text
NGFont.bodyM   = 16pt, Regular  // Default body text
NGFont.bodyS   = 14pt, Regular  // Small body text

// Labels
NGFont.labelM  = 16pt, Medium   // Button labels
NGFont.labelS  = 14pt, Medium   // Form labels
NGFont.caption = 12pt, Regular  // Captions, metadata
```

### Typography Guidelines

- **Line Height**: 1.4x for body text, 1.2x for titles
- **Letter Spacing**: Default system spacing
- **Text Color**: Use `NGColor.textPrimary` and `NGColor.textSecondary`
- **Accessibility**: Minimum 16pt for body text, scalable with Dynamic Type

---

## 📐 Spacing & Layout

### Spacing System

```swift
NGSize.spacingXS = 4pt   // Tight spacing
NGSize.spacingS  = 8pt   // Small spacing
NGSize.spacingM  = 16pt  // Default spacing
NGSize.spacingL  = 24pt  // Large spacing
NGSize.spacingXL = 32pt  // Extra large spacing
```

### Layout Grid
- **Margins**: 16pt on iPhone, 20pt on iPad
- **Gutters**: 16pt between columns
- **Columns**: 2-3 on iPhone, 4-6 on iPad

### Corner Radius

```swift
NGSize.cornerRadiusS = 8pt   // Small elements
NGSize.cornerRadius  = 12pt  // Default buttons, cards
NGSize.cornerRadiusL = 16pt  // Large cards, modals
```

---

## 🧩 Components

### Primary Button

**Usage**: Main call-to-action buttons
**Specs**: 
- Height: 48pt
- Corner radius: 12pt
- Background: `NGColor.primary`
- Text: White, 16pt Medium

```swift
PrimaryButton(title: "Continue") {
    // Action
}
```

### Macro Bar

**Usage**: Displaying macro nutrient progress
**Specs**:
- Height: 8pt progress bar
- Colors: Green (in range), Orange (below), Red (over)
- Background: `NGColor.gray2`

### Calorie Ring

**Usage**: Circular progress for calorie tracking
**Specs**:
- Diameter: 120pt
- Stroke width: 12pt
- Colors: Dynamic based on target range

### Score Ring

**Usage**: Lifestyle score visualization
**Specs**:
- Diameter: 100pt
- Stroke width: 12pt
- Emojis: 🔥 (≥8), 🙂 (5-7.9), 😬 (<5)

---

## 🖼️ Iconography

### Icon Style
- **Style**: San Francisco Symbols (system icons)
- **Weight**: Regular for body text size, Medium for larger sizes
- **Sizes**: 16pt, 24pt, 32pt standard sizes

### Icon Usage
- Use semantic, recognizable symbols
- Maintain consistent visual weight
- Pair with text labels when meaning is unclear

---

## 🌊 Animation & Motion

### Animation Principles
- **Duration**: 0.3s for most interactions
- **Easing**: `easeInOut` for natural feel
- **Purpose**: Provide feedback, guide attention, create delight

### Common Animations
- **Button tap**: Scale down 0.95x with haptic feedback
- **Loading states**: Subtle pulse or progress indicators
- **Transitions**: Slide or fade between screens

---

## ♿ Accessibility

### Requirements
- **Contrast**: Minimum 4.5:1 for normal text, 3:1 for large text
- **Touch targets**: Minimum 44x44pt
- **Dynamic Type**: Support all text sizes
- **VoiceOver**: Meaningful labels and hints

### Testing Checklist
- [ ] VoiceOver navigation works smoothly
- [ ] All interactive elements have accessible labels
- [ ] Color is not the only way to convey information
- [ ] Animations respect reduced motion preference

---

## 📱 Platform Guidelines

### iOS Specific
- Follow Human Interface Guidelines
- Use platform-native navigation patterns
- Respect system UI elements (safe areas, status bar)
- Support Dark Mode (coming in v2)

### Device Support
- **iPhone**: iOS 17+ (primary focus)
- **Orientation**: Portrait only for now
- **Screen sizes**: 5.4" to 6.7" optimization

---

## 🎨 Implementation

### Theme Usage

```swift
// Import theme utilities
import SwiftUI

// Use theme colors
.foregroundColor(NGColor.primary)
.background(NGColor.surface)

// Use theme fonts
.font(NGFont.titleM)

// Use theme spacing
.padding(NGSize.spacingM)
```

### Component Organization
```
Shared/
├── Components/      # Reusable UI components
├── Utilities/       # Theme, extensions, helpers
└── Models/          # Data models
```

---

## 🔄 Evolution

This design guide is a living document that will evolve with the product.

### Upcoming Additions
- Dark mode color palette
- Tablet-specific layouts
- Micro-interactions library
- Localization guidelines

### Change Log
- **v1.0** (Dec 2024): Initial design system
- Future versions will be documented here

---

## 📚 Resources

### Design Files
- Figma: [Link to be added]
- Sketch: [Link to be added]

### Code References
- `Theme.swift`: Color, typography, and spacing constants
- `Components/`: Reusable UI components
- SwiftUI documentation for platform guidelines

---

*For questions about this design guide, contact the design team or create an issue in the repository.* 