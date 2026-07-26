# Godot 4.7 Essentials — 3D Project Guide

Tailored to this project's config: **Godot 4.7**, **GL Compatibility** renderer, **Jolt Physics** for 3D. Keep this file as a living reference as the project grows.

---

## 1. Core Concepts

### Scenes
Everything in Godot is a **Scene** — a tree of **Nodes** saved to a `.tscn` file. A scene can be instanced inside another scene like a reusable component/prefab. There's no strict "one giant scene" model — you build small, focused scenes and combine them.

### Nodes
The base building block. Every node has a type (`Node3D`, `MeshInstance3D`, `CharacterBody3D`, etc.), a position in the tree, and a lifecycle (`_ready`, `_process`, `_physics_process`).

### The Scene Tree
At runtime, all scenes are merged into one **SceneTree**, rooted at your main scene. Nodes talk to each other via:
- **Parent/child relationships** (`get_parent()`, `get_node()`, `$NodePath`)
- **Groups** (tag-based, e.g. `add_to_group("enemies")`)
- **Signals** (events, decoupled communication)
- **Autoloads/Singletons** (global access, used sparingly)

### GDScript vs C#
GDScript is the default, fast to iterate, tightly integrated with the editor. C# is available if you need stronger typing/performance-critical code or come from a C# background. Don't mix unless you have a reason — pick one primary language.

---

## 2. Essential 3D Node Types

| Node | Purpose |
|---|---|
| `Node3D` | Base transform node (position/rotation/scale) for anything in 3D space |
| `MeshInstance3D` | Renders a `Mesh` resource (visual only, no collision) |
| `CollisionShape3D` | Defines a physical shape; must be a child of a physics body/area |
| `StaticBody3D` | Immovable collision (floors, walls, terrain) |
| `RigidBody3D` | Fully physics-simulated body (falls, bounces, affected by forces) — driven by **Jolt** in this project |
| `CharacterBody3D` | Kinematic body for player/enemy controllers; you code movement via `move_and_slide()` |
| `Area3D` | Non-solid trigger volume (detects overlaps, doesn't collide physically) |
| `Camera3D` | Viewport camera; only one is "current" per viewport |
| `DirectionalLight3D` | Sun-like light, casts uniform shadows |
| `OmniLight3D` / `SpotLight3D` | Point/cone lights |
| `WorldEnvironment` | Global environment settings: sky, fog, tonemapping, ambient light |
| `AnimationPlayer` / `AnimationTree` | Keyframe & state-machine driven animation |
| `Skeleton3D` | Bone hierarchy for skinned meshes |
| `NavigationRegion3D` / `NavigationAgent3D` | Pathfinding |
| `AudioStreamPlayer3D` | Positional 3D audio |

### GL Compatibility renderer notes
Since this project uses **GL Compatibility** (not Forward+), be aware:
- No SDFGI, no volumetric fog, limited light count per mesh (baked lightmaps are the practical GI solution).
- Prefer **baked lighting** (`LightmapGI`) or simple real-time lights + `VoxelGI`/`SDFGI` are **not available** — stick to `LightmapGI` or fully dynamic simple lighting.
- Fewer expensive post-processing effects (glow/SSAO still work but are costlier). Test performance on target hardware early, especially mobile/low-end.

---

## 3. Physics: Jolt Specifics

This project uses `3d/physics_engine="Jolt Physics"` instead of the default Godot Physics.

- API is the same (`RigidBody3D`, `CharacterBody3D`, etc.) — Jolt is a drop-in backend, more accurate/stable, better performance with many bodies.
- Slight differences: friction/bounce combine modes, joint behavior, and continuous collision detection (CCD) may behave more predictably than default.
- For player controllers, `CharacterBody3D` + `move_and_slide()` is still the standard approach; Jolt mainly improves `RigidBody3D` and joints.
- Use **Physics Layers/Masks** (Project Settings → Layer Names → 3D Physics) to name your collision layers instead of leaving them as "Layer 1, 2, 3..." — this avoids bugs from mismatched masks.

---

## 4. Composition — The Godot Way

Godot deliberately favors **composition over inheritance**. This is the single most important architectural habit to build early.

### 4.1 Scenes as components
Instead of one deep inheritance chain (`Enemy → FlyingEnemy → FlyingShootingEnemy`), build small scenes that do one thing and compose them as children:

```
Player (CharacterBody3D)
├── MeshInstance3D
├── CollisionShape3D
├── Camera3D (or a SpringArm3D + Camera3D for 3rd person)
├── HealthComponent (Node) — exposes signals: health_changed, died
├── WeaponMount (Node3D)
│   └── Weapon (instanced scene, swappable)
└── HitboxComponent (Area3D)
```

Each "Component" node is its own small scene (e.g. `health_component.tscn`) that can be dropped into *any* entity — player, enemy, destructible crate — without rewriting logic.

### 4.2 Composition patterns to use

- **Component nodes**: Small, single-responsibility scripts attached to a `Node`/`Area3D`/`Node3D` and instanced as children (health, hitbox/hurtbox, inventory, interaction). Communicate up via **signals**, not by reaching into the parent.
- **Signals over hard references**: A `HealthComponent` emits `died`; it never needs to know what the parent is. The parent connects to the signal.
  ```gdscript
  # health_component.gd
  extends Node
  signal died
  signal health_changed(current: int, max: int)

  @export var max_health: int = 100
  var current_health: int

  func _ready() -> void:
      current_health = max_health

  func take_damage(amount: int) -> void:
      current_health = max(0, current_health - amount)
      health_changed.emit(current_health, max_health)
      if current_health == 0:
          died.emit()
  ```
- **Scene inheritance sparingly**: You *can* inherit scenes (`Enemy.tscn` → `Goblin.tscn`), and it's fine for small variations, but prefer composition once behavior diverges significantly — inheritance chains get rigid fast.
- **Resources for data, not just scenes**: Use custom `Resource` scripts (`.tres`) for shared data — e.g. a `WeaponData` resource holding damage/fire-rate/mesh — so designers can create variants without touching scenes/code.
  ```gdscript
  # weapon_data.gd
  class_name WeaponData
  extends Resource

  @export var damage: int = 10
  @export var fire_rate: float = 0.2
  @export var mesh: Mesh
  ```
- **Autoloads only for true globals**: `GameManager`, `EventBus`/`Signals` singleton, `AudioManager`. Don't use autoloads as a dumping ground — most cross-node communication should be signals/groups, not global state.
- **Groups for loose queries**: `get_tree().call_group("enemies", "take_damage", 10)` when you need to broadcast without direct references.

### 4.3 Why this matters for 3D specifically
3D projects tend to have many entity types (props, enemies, interactables, vehicles). Composition lets you mix traits — e.g. a `Destructible` crate reuses `HealthComponent` and `HitboxComponent` from the player without any shared base class beyond `Node3D`.

---

## 5. Project Structure (recommended)

```
res://
├── assets/
│   ├── models/        # imported .glb/.fbx meshes
│   ├── materials/
│   ├── textures/
│   └── audio/
├── scenes/
│   ├── main.tscn              # entry point (set in Project Settings)
│   ├── levels/
│   ├── entities/
│   │   ├── player/
│   │   └── enemies/
│   └── components/            # reusable component scenes
│       ├── health_component.tscn
│       └── hitbox_component.tscn
├── scripts/
│   ├── components/
│   ├── autoload/               # singleton scripts
│   └── resources/              # custom Resource classes
├── ui/
└── addons/                     # plugins
```

Set your entry scene: **Project → Project Settings → Application → Run → Main Scene**.

---

## 6. Best Practices

### Scripting
- Use `@export` for anything a designer/you should tweak in the Inspector instead of hardcoding.
- Use `class_name` on reusable scripts (e.g. `class_name HealthComponent`) so they're typed and appear as node types.
- Prefer **typed GDScript** (`var health: int = 100`, `func take_damage(amount: int) -> void:`) — catches bugs early and gives better autocomplete.
- Cache node references in `_ready()` with `@onready var mesh: MeshInstance3D = $MeshInstance3D` instead of repeated `get_node()` calls.
- Never use `get_node("../../Something")` style fragile paths across scenes — export a `NodePath`/direct node reference or use signals/groups instead.

### Signals & decoupling
- A node should not need to know about its parent's implementation. Emit a signal and let the listener decide what to do.
- Connect signals in code (`_ready()`) when the relationship is dynamic, or in the editor when it's fixed and simple.

### Performance
- Use `_physics_process(delta)` for anything physics/movement related (fixed timestep); use `_process(delta)` for visual-only per-frame updates.
- Avoid `get_node()`/string lookups every frame — cache in `@onready`.
- Batch static geometry; use `MultiMeshInstance3D` for large numbers of identical objects (foliage, rocks, crowds).
- Use LOD (`VisibleOnScreenNotifier3D`, mesh LODs, `GeometryInstance3D.lod_bias`) for large scenes.
- Bake lighting (`LightmapGI`) where possible under GL Compatibility to keep real-time light count low.
- Profile with the built-in **Debugger → Monitors/Profiler** before optimizing blindly.

### Physics & collisions
- Name your physics layers in Project Settings; never rely on layer numbers alone.
- Keep collision shapes simple (box/capsule/cylinder) over convex/trimesh where possible for performance.
- Use `Area3D` for triggers/detection, physics bodies only for things that need actual collision response.

### Version control & assets
- Commit `.tscn`/`.tres` as **text** (default) — diffable and mergeable, unlike binary formats.
- Add a `.gitignore` for `.godot/` (the local cache/import folder) and `export/` build output.
- Keep imported 3D assets (`.import` files) — they're regenerated, but committing them avoids re-import churn for teammates.

### Editor workflow
- Use **scene inheritance** or **instancing** to reuse level pieces (modular level design with instanced prefabs).
- Organize the Inspector with `@export_group("Movement")` / `@export_category()` for scripts with many exported vars.
- Use **Tool scripts** (`@tool`) sparingly, only when you need editor-time behavior (custom gizmos, procedural preview).

### Input
- Define actions in **Project Settings → Input Map** (`move_forward`, `jump`, `interact`) instead of hardcoding `KEY_W`. Makes rebinding and cross-device support trivial.

---

## 7. A Minimal 3D Player Controller (starting point)

```gdscript
# player.gd
class_name Player
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()
```

Remember to define `move_left/right/forward/back` and `jump` in the Input Map first.

---

## 8. Learning Path / Next Steps

1. Build the player scene (`CharacterBody3D` + mesh + collision + camera rig).
2. Set up input actions.
3. Build one reusable component (`HealthComponent`) and prove it works on two different entities.
4. Set up an `EventBus`/`GameEvents` autoload only if you find yourself needing global cross-cutting signals (e.g., `game_paused`, `score_changed`).
5. Block out a level with `StaticBody3D` geometry, add `WorldEnvironment` + `DirectionalLight3D`, bake a `LightmapGI` pass.
6. Add `.gitignore` for `.godot/` and set up version control if not already done.

## References
- Official docs: https://docs.godotengine.org/en/stable/
- "Godot Best Practices" docs section: https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html
- Jolt Physics integration notes: https://docs.godotengine.org/en/stable/tutorials/physics/jolt_physics.html
