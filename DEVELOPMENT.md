# 弹幕生存游戏 - 开发文档

## 项目结构

### 场景文件 (*.tscn)
1. `main.tscn` - 主场景
   - 包含主要游戏元素：玩家、敌人生成器、背景
   - 场景树结构：
     ```
     Main (Node2D)
     ├── Background (ColorRect)
     ├── Player (CharacterBody2D)
     ├── EnemySpawner (Node2D)
     └── UI (CanvasLayer)
     ```

2. `scenes/Player.tscn` - 玩家场景
   - 包含玩家相关组件：碰撞体、精灵、武器、相机
   - 场景树结构：
     ```
     Player (CharacterBody2D)
     ├── CollisionShape2D
     ├── Sprite2D
     ├── Camera2D
     └── WeaponHolder
         └── Weapon
     ```

3. `scenes/Enemy.tscn` - 敌人场景
   - 包含敌人相关组件：碰撞体、精灵、hitbox
   - 场景树结构：
     ```
     Enemy (CharacterBody2D)
     ├── CollisionShape2D
     ├── Sprite2D
     └── Hitbox (Area2D)
         └── CollisionShape2D
     ```

4. `scenes/Weapon.tscn` - 武器场景
   - 包含武器相关组件：计时器、发射点
   - 场景树结构：
     ```
     Weapon (Node2D)
     ├── AttackTimer
     └── Muzzle (Marker2D)
     ```

### 脚本文件 (*.gd)

1. `scripts/Player.gd` - 玩家控制脚本
   - 主要功能：
     * 移动控制
     * 生命值系统
     * 经验值系统
     * 升级系统
   - 关键属性：
     * `move_speed: float = 300.0`
     * `max_health: float = 100.0`
     * `current_exp: float = 0`
     * `level: int = 1`

2. `scripts/Weapon.gd` - 武器系统脚本
   - 主要功能：
     * 自动瞄准
     * 子弹生成
     * 特殊效果处理
   - 关键属性：
     * `damage: float = 20.0`
     * `attack_speed: float = 2.0`
     * `attack_range: float = 500.0`
     * 各种子弹效果属性（穿透、弹射等）

3. `scripts/Bullet.gd` - 子弹行为脚本
   - 主要功能：
     * 子弹移动
     * 碰撞检测
     * 特殊效果实现
   - 关键属性：
     * `speed: float = 500.0`
     * `damage: float = 20.0`
     * 各种特殊效果标志

4. `scripts/Enemy.gd` - 敌人行为脚本
   - 主要功能：
     * 追踪玩家
     * 碰撞伤害
     * 死亡处理
   - 关键属性：
     * `move_speed: float`
     * `damage: float`
     * `health: float`

5. `scripts/EnemySpawner.gd` - 敌人生成器脚本
   - 主要功能：
     * 定时生成敌人
     * 难度递增
     * 位置计算
   - 关键属性：
     * `base_spawn_interval: float`
     * `min_spawn_interval: float`
     * `spawn_decrease_rate: float`

6. `scripts/LevelUpUI.gd` - 升级界面脚本
   - 主要功能：
     * 升级选项显示
     * 效果应用
     * 组合升级检测
   - 关键数据结构：
     * `base_upgrades: Dictionary`
     * `combo_upgrades: Dictionary`
     * `obtained_upgrades: Array`

7. `scripts/Camera.gd` - 相机控制脚本
   - 主要功能：
     * 跟随玩家
     * 平滑移动

### 升级系统详解

1. 基础升级
   ```gdscript
   var base_upgrades = {
       "multi_shot": {
           "name": "三重射击",
           "description": "同时发射三发子弹",
           "effect": "_apply_multi_shot"
       },
       // ... 其他基础升级
   }
   ```

2. 组合升级
   ```gdscript
   var combo_upgrades = {
       "nuclear_shot": {
           "name": "核爆强化",
           "description": "增强爆炸范围和伤害",
           "requires": ["explosive", "piercing"],
           "effect": "_apply_nuclear_shot"
       },
       // ... 其他组合升级
   }
   ```

### 子弹效果系统

1. 基础属性
   - 速度
   - 伤害
   - 方向

2. 特殊效果
   - 穿透
   - 弹射
   - 追踪
   - 爆炸
   - 分裂
   - 激光

### 关键机制

1. 敌人生成
   - 在玩家周围固定范围随机生成
   - 生成间隔随时间减少
   - 生成数量随时间增加

2. 升级触发
   - 达到经验值阈值
   - 显示升级UI
   - 暂停游戏
   - 应用选择的效果

3. 子弹生成
   - 从角色边缘发射
   - 自动瞄准最近敌人
   - 应用所有激活的特效

## 开发注意事项

1. 性能优化
   - 使用对象池管理子弹
   - 及时清理失效对象
   - 减少不必要的调试输出

2. 代码维护
   - 保持模块化结构
   - 使用清晰的命名
   - 添加必要的注释

3. 游戏平衡
   - 升级效果叠加要考虑平衡
   - 敌人难度曲线要平滑
   - 保持游戏的可玩性

## 调试信息

1. 关键调试输出
   - 敌人生成: "Spawning enemies: {count}"
   - 武器状态: "Weapon ready, attack speed: {speed}"
   - 升级选择: "Selected upgrade: {name}"

2. 性能监控
   - 敌人数量
   - 子弹数量
   - FPS

## 待优化项目

1. 技术优化
   - [ ] 实现对象池系统
   - [ ] 优化碰撞检测
   - [ ] 减少垃圾收集

2. 游戏性优化
   - [ ] 平衡升级效果
   - [ ] 优化敌人生成算法
   - [ ] 改进子弹效果视觉表现

## 版本控制
- 主分支：main
- 开发分支：dev
- 特性分支：feature/*
- 发布分支：release/*

## 构建说明
1. Godot版本：4.2.1
2. 导出平台：Windows/Linux/Mac
3. 最小系统要求：待定

## 项目结构
```
.
├── scenes/          # 场景文件
│   ├── Weapon.tscn  # 武器场景
│   ├── Enemy.tscn   # 敌人场景
│   └── main.tscn    # 主场景
├── scripts/         # 脚本文件
│   ├── Weapon.gd    # 武器逻辑
│   ├── Bullet.gd    # 子弹逻辑
│   ├── Enemy.gd     # 敌人逻辑
│   └── LevelUpUI.gd # 升级UI逻辑
└── docs/           # 文档
    ├── TECHNICAL.md # 技术文档
    └── CHANGELOG.md # 更新日志
```

## 核心系统

### 武器系统
- 自动瞄准最近敌人
- 支持多种子弹效果
- 可升级属性系统

### 敌人系统
- 自动生成敌人
- 追踪玩家
- 掉落经验值

### 升级系统
- 经验值收集
- 等级提升
- 武器升级选择

### 重启系统
- 重置玩家状态
- 清除场景对象
- 重置武器属性

## 开发规范

### 代码风格
- 使用 GDScript
- 遵循 Godot 命名规范
- 添加必要的注释

### 文件组织
- 场景文件放在 scenes/ 目录
- 脚本文件放在 scripts/ 目录
- 文档放在 docs/ 目录

### Git 提交规范
- feat: 新功能
- fix: 修复问题
- docs: 文档更新
- refactor: 代码重构
- style: 代码格式调整

## 开发计划

### 当前版本 (v1.1)
- [x] 完善重启功能
- [x] 修复重启时的问题
- [ ] 添加更多敌人类型
- [ ] 优化升级系统

### 下个版本 (v1.2)
- [ ] 添加 Boss 系统
- [ ] 添加新的武器效果
- [ ] 优化游戏平衡性 