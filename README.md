# 麦浪争锋

俯视角像素风割麦对战原型。

## 玩法

- 每局 2 分钟
- 割麦累计得分，比赛结束时总收割数更多的一方获胜
- 割过的麦子会在 20 秒后重新长出
- 可以挥镰攻击对手，被击倒后 3 秒复活
- 当前版本为玩家与 AI 进行 2v2 对战

## 操作

- `WASD` 或方向键：移动
- 鼠标：瞄准
- 鼠标左键或空格：挥镰攻击
- `R`：比赛结束后重新开始

## 运行

使用 Godot 4.6 或更高版本打开 `project.godot`。

## 代码结构

- `scripts/WheatArena.gd`：主比赛场景，暂时保留输入、流程编排和大部分绘制逻辑
- `scripts/FighterModel.gd`：战斗中的纯数据模型，例如角色、飞镰、道具、特效、麦秆
- `scripts/CombatState.gd`：比分结算和比赛状态规则
- `scripts/WheatField.gd`：麦田格子坐标、索引和再生计时逻辑
- `scripts/NetworkSync.gd`：联网同步 payload 的序列化/反序列化辅助
- `scripts/ArenaRenderer.gd`：场内渲染辅助，例如角色方向和 sprite sheet 帧定位
- `scripts/MapLayoutData.gd`：地图格子布局生成
- `scripts/MapConfig.gd`：地图 JSON 配置读写
- `scripts/CharacterCatalog.gd`：角色 manifest 和贴图读取

联网同步策略：高频状态包只同步角色、飞镰、道具、屏障和必要比赛状态；麦田格子使用增量 `wheat_delta`，并每秒做一次完整校正；火花、火星、拼刀等纯视觉效果通过一次性 `events` 发送后由客户端本地播放。

## 角色资产

当前项目带有一套可运行的像素角色资产：

- `assets/characters/manifest.json`：角色清单
- `assets/characters/*/portrait.png`：512×512 头像/立绘占位
- `assets/characters/*/sheet.png`：384×768 动作表
- `assets/characters/preview.png`：12 个角色总览

动作表规格：

- 单帧尺寸：64×64
- 每行动画：6 帧
- 方向：down、up、right、left
- 动作：idle、run、slash

重新生成资产：

```bash
python3 tools/generate_character_assets.py
```

如果以后要换成 AI 精修立绘或手绘 sprite，只要保持同名 PNG 和动作表规格不变，战斗脚本不需要改。
