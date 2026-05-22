# FLUTTER DEVELOPMENT CONTEXT 

You are working inside an existing Flutter project.

This file is a rule system for code generation.

Goal:

* speed up development
* reduce boilerplate work
* preserve developer skill (no full replacement behavior)

You are a code assistant, not the main architect.

---

# 🧠 CORE PRINCIPLE

* Assist, do not replace thinking
* Scaffold code, do not fully complete complex logic
* Prefer minimal, extendable outputs

---

# 🚨 ABSOLUTE RULES

* No imports unless requested
* No new dependencies
* No UI redesign unless asked
* No animations unless requested
* No full feature completion in one shot
* No explanations
* Output ONLY code

---

# ⚖️ CODE GENERATION RULE

### Allowed

* widget skeletons
* boilerplate
* UI structure
* simple logic
* reusable patterns

### Not allowed

* full end-to-end features
* hidden architecture decisions
* complete business logic

If logic is complex → leave TODOs.

---

# 🧠 THINKING MODE

Assume:

* code will be extended by developer
* missing logic will be filled manually
* minimal change is preferred

---

# 📦 PROJECT STRUCTURE

lib/
core/
services/
utils/
constants/
features/
feature_name/
ui/
widgets/
controller/
model/

---

# 🎨 UI RULES

* minimal UI only
* no visual improvements unless asked
* use existing theme
* handle loading/error/empty states

---

# 🧱 CODE RULES

* smallest possible change
* no unnecessary abstraction
* keep functions small

---

# 🔄 STATE

* use existing system
* if unsure → setState only
* no new patterns

---

# 🌐 API

* keep inside services layer
* no direct API calls in UI
* no new architecture

---

# 🚫 ANTI-PATTERNS

Never:

* add imports
* add libraries
* restructure project
* rewrite full features
* overengineer UI
* add unnecessary abstraction

---

# ⚠️ FLUTTER SAFETY + REAL-WORLD PITFALL RULES

## 🧠 Build Method Safety

* NEVER create controllers, animations, or recognizers inside build() unless stateless and disposable is NOT required
* Avoid allocations inside build() when state persists across frames

---

## 🧹 Gesture / Listener Safety

* Any TapGestureRecognizer, LongPressGestureRecognizer, or similar MUST be:

  * created in initState
  * disposed in dispose()

Example rule:

* If recognizer is used in TextSpan → store in list → dispose all

---

## 🔁 Rebuild Safety

* Do not mutate state inside build()
* Do not trigger setState inside build()
* Avoid side effects in widget tree construction

---

## 🧠 List / Map Safety

* When using map with index, ALWAYS use:

  * asMap().entries
  * or List.generate

Never assume map provides index

---

## 🧯 Lifecycle Safety

* Always check mounted before setState in async operations

---

## 📦 Controller Safety

* Controllers (TextEditingController, AnimationController, ScrollController)

  * must be disposed in dispose()

---

## ⚡ Performance Safety

* Prefer const widgets when possible
* Avoid rebuilding large widget trees unnecessarily
* Keep build methods pure

---

## 🎯 Gesture Pattern Rule (IMPORTANT)

When using TextSpan recognizer pattern:

* DO NOT create recognizers inside build() for production widgets
* Instead:

  * pre-create in initState
  * store in List<TapGestureRecognizer>
  * assign by index in build()
  * dispose in dispose()

---

# 🧠 THINKING RULE

If a Flutter feature:

* holds memory
* listens to gestures
* uses controllers

→ it MUST have lifecycle management

---

# 📦 CODE GENERATION RULE (

### Allowed

* widget skeletons
* boilerplate
* UI structure
* simple logic
* reusable patterns

### Not allowed

* full end-to-end features
* hidden architecture decisions
* complete business logic

If logic is complex → leave TODOs.

---

# 🧠 THINKING MODE

Assume:

* code will be extended by developer
* missing logic will be filled manually
* minimal change is preferred

---

# 🎨 UI RULES

* minimal UI only
* no visual improvements unless asked
* use existing theme
* handle loading/error/empty states

---

# 🧱 CODE RULES

* smallest possible change
* no unnecessary abstraction
* keep functions small

---

# 🔄 STATE

* use existing system
* if unsure → setState only
* no new patterns

---

# 🌐 API

* keep inside services layer
* no direct API calls in UI
* no new architecture

---

# 🚫 ANTI-PATTERNS

Never:

* add imports
* add libraries
* restructure project
* rewrite full features
* overengineer UI
* add unnecessary abstraction

---

# 🧠 OUTPUT FORMAT

* ONLY code
* minimal changes
* include TODOs for missing logic

---

# 🎯 INTENT RULE

If unclear:

* choose simplest solution
* leave gaps instead of guessing
* avoid assumptions

---

# 🧩 PATTERN LIBRARY (REFERENCE)

## Screen

class SampleScreen extends StatelessWidget {
const SampleScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Title")),
body: const Center(child: Text("Content")),
);
}
}

## Button

class PrimaryButton extends StatelessWidget {
final String text;
final VoidCallback onPressed;

const PrimaryButton({
super.key,
required this.text,
required this.onPressed,
});

@override
Widget build(BuildContext context) {
return ElevatedButton(
onPressed: onPressed,
child: Text(text),
);
}
}

## Card

class CustomCard extends StatelessWidget {
final String title;
final String subtitle;

const CustomCard({
super.key,
required this.title,
required this.subtitle,
});

@override
Widget build(BuildContext context) {
return Card(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(title),
const SizedBox(height: 8),
Text(subtitle),
],
),
),
);
}
}

## State Example

class Counter extends StatefulWidget {
const Counter({super.key});

@override
State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
int value = 0;

void increment() {
setState(() => value++);
}

@override
Widget build(BuildContext context) {
return Column(
children: [
Text("Value: $value"),
ElevatedButton(
onPressed: increment,
child: const Text("Increase"),
),
],
);
}
}

## API Service

class ApiService {
Future<String> fetchData() async {
return "data";
}
}

## Stream

Stream<String> streamData() async* {
for (int i = 0; i < 10; i++) {
await Future.delayed(const Duration(milliseconds: 200));
yield "Item $i";
}
}

---

# $1

---

# 🧩 FLUTTER TEXT INTERACTION ADDON

## 🧩 Text Interaction (RichText / TextSpan) Rules (IMPORTANT)

* DO NOT use TapGestureRecognizer as a hover system
* TapGestureRecognizer is tap-only and unreliable for hover/continuous state

### ❌ Anti-pattern

* Using onTapDown / onTapUp / onTapCancel as hover tracking
* Expecting per-character hover behavior inside TextSpan to behave like widgets

### ⚠️ Correct understanding

* TextSpan = rendering layer (NOT interaction layer)
* Interaction inside TextSpan is limited and lifecycle-sensitive

### ✅ Allowed usage

* onTap only (simple interactions)

---

## 🧭 Hover / Desktop Interaction Rules

* Hover behavior MUST use MouseRegion
* MouseRegion does NOT work inside TextSpan

### Required restructure when hover is needed:

* Replace TextSpan approach with WidgetSpan or widget-based layout
* Use MouseRegion for enter/exit state

---

## 🧱 Interactive Text Pattern Rule (PER-LETTER UI)

If per-letter interaction is required:

* DO NOT use RichText + TapGestureRecognizer for full interaction systems

### Preferred structure:

* WidgetSpan
* MouseRegion (hover)
* GestureDetector (tap)

---

## 🚨 Gesture Misuse Rule

* TapGestureRecognizer is NOT a state manager
* Do not use it for hover simulation or UI state tracking
