# Anime Simulator (Roblox)

Protótipo de simulador de anime em Roblox (Lua) com:
- Sistema de moedas (Coins)
- Kills por ilha e progressão (desbloqueio por requisito de kills)
- NPCs com respawn automático e IA simples de perseguição/vagar
- Teleporte para próxima ilha quando atingir o requisito
- Interface de jogador mostrando progresso e botão de viagem

## Estrutura recomendada no Explorer

ReplicatedStorage/
  Modules/
    Config.lua
    NPCAI.lua
  NPCs/
    Bandit (Model com Humanoid + HumanoidRootPart)
    SandThug (Model)
    SkyNinja (Model)
  Remotes/ (criado pelo Bootstrap)
ServerScriptService/
  Bootstrap.server.lua
  Leaderstats.server.lua
  Progression.server.lua
  NPCSpawner.server.lua
  Combat.server.lua
  Teleport.server.lua
StarterPlayer/
  StarterPlayerScripts/
    ClientCombat.client.lua
  StarterGui/
    StatsGui.client.lua
Workspace/
  Islands/
    start/
      PlayerSpawns/
        Spawn1 (Part)
      NPCSpawnPoints/
        SpawnA (Part) ...
    desert/
      PlayerSpawns/
        Spawn1
      NPCSpawnPoints/
        SpawnA ...
    sky/
      PlayerSpawns/
        Spawn1
      NPCSpawnPoints/
        SpawnA ...

Cada ilha deve ter:
- Folder PlayerSpawns com pelo menos um Part para spawn do jogador.
- Folder NPCSpawnPoints com vários Parts para spawn de NPC.

## Progressão
Você inicia em start. Ao matar NPCs dessa ilha, aumenta IslandKills. Quando IslandKills >= RequiredKillsForNext da ilha atual, o botão de viagem aparece para ir à próxima. Teleport reset em IslandKills.

## Ajustes rápidos
- Dano base do jogador: StarterPlayerScripts/ClientCombat.client.lua (BASE_DAMAGE)
- Configuração de ilhas e NPCs: Modules/Config.lua
- Recompensas de moedas e vida/dano dos NPCs: Config.lua (NPCTypes)

## Segurança
- Validação de alcance e cooldown de ataque no servidor.
- Dano somente via RemoteEvent controlado.
- Recompensa no server usando tag creator.

## Próximos passos (opcional)
- Adicionar DataStore para salvar Coins, ilha atual, etc.
- Adicionar sistema de habilidades/espadas.
- Efeitos visuais e sons ao atacar.

## Licença
MIT (ver LICENSE).

Bom desenvolvimento!
