# QuantumCore — Especificação de Design & Prompt Mestre

> Documento de referência único: da experiência em alta fidelidade até os 8 modelos 3D de partículas e a conexão com o projeto Reality Composer Pro / RealityKit.
> Status: ~95% fechado. Itens marcados **[preencher]** dependem de decisão sua.

---

## 0 · Visão geral

**Produto:** experiência imersiva de física quântica (visionOS/RealityKit) onde o usuário explora partículas fundamentais em 3D. A partícula-foco da narrativa é o **nêutron**.

**Princípio de identidade (regra de ouro):** cada partícula é reconhecida por **modelo 3D + cor, sempre os dois juntos** — nunca só a forma, nunca só a cor.

**Pipeline técnico:** modelagem em three.js → export **GLB** → conversão **USDZ** → **Reality Composer Pro** (cenas + animações) → **RealityKit** (app, loop por código).

---

## 1 · Design system — QuantumCore UI

- **Tipografia:** VT323 (monoespaçada, estética terminal/retro-técnica).
- **Fundo base:** `#05060a` (quase preto). Máx. 1–2 cores de fundo em toda a experiência.
- **Famílias de cor (paleta "Nova Direção"):**
  - **Estrutural** — âmbar `#FFB74D` (no design system). *Nos modelos 3D, a família estrutural — quarks e glúon — foi resolvida em **roxo**, decisão travada durante a modelagem.*
  - **Transformação** — magenta `#FF3EC9` (bósons W e Z).
- **Sem tropes de "AI slop":** sem gradientes agressivos de fundo, sem emoji, sem bloom.

### Protótipo de alta fidelidade (telas 2D)
- Direção visual: **[preencher]** — layout das telas, navegação, tipos de card/painel.
- Referências conhecidas herdadas do protótipo:
  - Glúon era **cinza**.
  - Bóson W era uma **esfera com gradiente ciano↔magenta**.
- Fluxos de tela / onboarding: **[preencher]**.

---

## 2 · Restrições de modelagem 3D (valem para TODAS as partículas)

- **Materiais:** apenas PBR (`MeshStandardMaterial`). **Sem shaders custom. Sem post-processing / sem bloom.**
- **Brilho:** só via **emissive** no próprio material (sobrevive ao export, não depende de bloom).
- **Topologia:** low-poly, **50–300 triângulos** por partícula — exceção: eletrosfera e átomo (mais densos).
- **Nomes:** toda malha e material tem **nome explícito** (ex.: `energy_mass`, `quark_up_nucleo`, `boson_w_halo`) — é por esses nomes que se mira a animação no RCP.
- **Escala:** ~0,3–0,55 unidades (boa escala para RealityKit; 1 unidade = 1 metro).
- **Animação:** **nada é baked na geometria** — todo movimento é descrito para ser montado no RCP.

---

## 3 · Catálogo das 8 partículas

### 3.1 Eletrosfera
- **Conceito:** nuvem de probabilidade. Branco/cinza translúcida com leve **tom verde**.
- **Estrutura:** 3 camadas — `eletrosfera_shell_mid`, `eletrosfera_shell_outer`, `eletrosfera_aura`.
- **Núcleo** aparece em escala mínima no interior.
- **Material:** translúcido (transparência PBR), leve emissivo esverdeado.

### 3.2 Núcleo
- **Conceito:** massa de energia densa, **branca, opaca**, geoide.
- **Malhas:** `energy_mass` (corpo) + `heart` (miolo, mais emissivo).
- **Brilho:** emissive branco (intensidade ~2–3 no RCP para ficar "aceso").

### 3.3 Átomo
- **Composição:** núcleo + eletrosfera juntos (escala A, núcleo ~0,01).

### 3.4 Elétron
- **Conceito:** distribuição de probabilidade — **nuvem dispersa de mini ecos-fantasma verdes** (`eletron_provavel` + `eletron_eco_1..N`). Sem posição fixa.
- **Cor:** verde.

### 3.5 Fóton
- **Conceito:** ponto de luz puro, **emissive-only**, sem corpo/halo, sem bloom.
- **Cor:** amarelo `#ffd400` (corpo emissivo), miolo `#fff59a`. Emissive intensity **8** (brilha bastante).
- **Malha:** `foton_ponto`.

### 3.6 Quarks (up & down)
- **Conceito:** blob denso e orgânico, família estrutural em **roxo**. Corpo + núcleo interno luminoso.
- **Up:** `#8B5CF6` (claro), **cheio/maior**.
- **Down:** `#1e0a5c` (muito escuro), **menor/irregular**.

### 3.7 Glúon
- **Conceito:** **sem massa** → energia, não matéria. **Fio ondulado** (squiggle, estilo diagrama de Feynman), translúcido e emissivo, **cinza** (`#c4cad3`). Modelo exportável = **um fio só**.
- **Função a transmitir:** **transmite/troca a cor entre os quarks**. Pode carregar cor, mas a leitura principal é a *transmissão*.
- **No nêutron:** vários fios formam a malha que tece os quarks; as cores viajam pelos fios de um quark a outro (o nêutron em si o usuário monta no RCP).

### 3.8 Bóson W
- **Conceito:** **extremamente massivo** → esfera **sólida, opaca, pesada** (oposto do glúon). Gradiente **ciano↔magenta** + **atmosfera/halo** de cor ao redor (conceito "E" aprovado).
- **Cores:** ciano `#00e5ff` ↔ magenta `#ff3ec9` (família Transformação). Halo aditivo.
- **Função:** força fraca; transforma quark (up↔down); carga elétrica — **decisão: NÃO representar +/−**, uma esfera única, sem símbolos.
- **Malhas:** `boson_w` (corpo), `boson_w_halo`, `boson_w_halo2`.

### 3.9 Bóson Z
- **Conceito:** **mesma forma do W** (coesão da força fraca) porém **neutro** → **azul escuro opaco**, monocromático (sem dualidade de cor), halo bem contido.
- **Cores:** corpo `#101d44`→`#2b4593`, halo `#1a2c66`.
- **Malhas:** `boson_z` (corpo), `boson_z_halo`, `boson_z_halo2`.

---

## 4 · Animações (montadas no RCP — nunca na geometria)

**Regra de loop com Transform By (cumulativo):** para cada eixo, **o produto de todos os multiplicadores de escala = 1,0**, senão a partícula deriva a cada ciclo. Rotação contínua = **Linear**; respiração = **Ease In Out**.

| Partícula | Animação idle |
|---|---|
| **Núcleo** | Spin multi-eixo (Linear) + respiração uniforme (par Transform By, 1,05 × 0,952, Ease In Out). Períodos casados (~2,5s). |
| **Eletrosfera** | Respiração **assimétrica** em 3 fases por camada. `shell_outer` **estufa pra fora**, `aura` **colapsa pra dentro**, defasadas 0,4s; `shell_mid` **parado** ancorando o centro. |
| **Elétron** | Cintilação dos ecos (pares Hide→Show) com **offsets escalonados** (fora de sincronia) + **Spin** (Linear, eixo único ~0,1,0) representando o spin intrínseco. |
| **Fóton** | Twinkle (pulso de escala rápido ~1s, Ease In Out) + spin leve opcional. Trajeto "andar" = Transform By de posição, **Linear**, **one-shot** (não loop). |
| **Quarks / Z** | Spin + respiração, mesma receita do núcleo. |
| **Glúon / W** | **Animação de material** (glúon = cor viajando pelo fio; W = gradiente girando/invertendo) → exige **Shader Graph**. *Nível avançado, ainda a fazer.* |

### Eletrosfera — valores aprovados (referência)
**`eletrosfera_shell_outer`** (bojo pra fora), Ease In Out:
- F1 (0→1,0s): X 1,28 · Y 1,05 · Z 1,20
- F2 (1,0→2,0s): X 0,85 · Y 1,02 · Z 0,88
- F3 (2,0→3,0s): X 0,919 · Y 0,934 · Z 0,947

**`eletrosfera_aura`** (colapso pra dentro, defasada 0,4s), Ease In Out:
- F1 (0,4→1,4s): X 0,78 · Y 0,82 · Z 1,05
- F2 (1,4→2,4s): X 1,05 · Y 0,95 · Z 1,10
- F3 (2,4→3,4s): X 1,221 · Y 1,284 · Z 0,866

Loop total da timeline: **~3,4s**.

---

## 5 · Projeto Reality Composer Pro

- **Um único projeto** (Swift Package): `QuantumScenes`, em `~/Developer/QuantumScenes` (`Package.swift`, `Sources/QuantumScenes/QuantumScenes.rkassets`). *Renomeado de "Quantum Core - Scenes" em 2026-07-21 — espaços/hífen no nome quebravam a resolução do SwiftPM no Xcode.* Já integrado ao `QuantumCore.xcodeproj` como pacote local.
- **Uma cena `.usda` por partícula/composição:** `Nucleo.usda`, `Eletron.usda`, `Foton.usda`, `Atomo.usda` (átomo referencia Eletrosfera + Núcleo)… as demais conforme forem prontas.
- **Referências:** cenas de composição (Átomo, evento) **referenciam** as cenas-fonte — editar a fonte propaga.
- **⚠️ Fora do iCloud:** manter o projeto em `~/Developer` (nunca sincronizada pelo macOS). iCloud cheio corrompeu arquivos antes. Atenção: `~/Documents` está com sincronização iCloud **ativada** nesta máquina — não deixar o projeto lá.
- **Conversão GLB→USDZ:**
  - **Blender** (QA) para materiais delicados: W, glúon, eletrosfera (vertex colors, transparência, emissivo).
  - **Reality Converter** para opacos simples: núcleo, quarks, Z.
  - **Up-axis Y:** no export USD do Blender, ativar **Convert Orientation** com **Forward −Z / Up Y** — o padrão do Blender (Z-up) dispara warning de referência no RCP em toda cena. Reality Converter (GLB→USDZ) não precisa: GLB já é Y-up. *Os 4 usdc existentes foram normalizados Z→Y em 2026-07-21 (só metadado, geometria intacta; backups em `QuantumScenes/backup-usdc-zup/`).*
- **Loop:** RCP desta versão **não tem toggle de loop** → feito por código.
- **Sem behaviors de "Play Timeline":** as cenas ficam só com a timeline, **sem** `OnAddedToScene` — o app dispara tudo por código com a variante `__auto_generated_looping` (ver `playAllTimelines` no `AtomView`). Behavior de play toca a timeline **uma vez** e atropela o loop do código. O RCP mostra um ⚠️ na cena por causa da timeline sem trigger — é esperado e inofensivo.

### Carregar e rodar em loop (RealityKit)

```swift
import SwiftUI
import RealityKit
import QuantumScenes

struct AtomoView: View {
    var body: some View {
        RealityView { content in
            if let atomo = try? await Entity(named: "Atomo", in: quantumScenesBundle) {
                content.add(atomo)
                for anim in atomo.availableAnimations {
                    atomo.playAnimation(anim.repeat())   // loop infinito
                }
            }
        }
    }
}
```

- `Entity(named: "<Cena>")` carrega a cena pelo nome do `.usda`. **Cenas em subpastas do `.rkassets` são endereçadas com o caminho:** `"Atomo/Atomo"`, `"Nucleo/Nucleo"` etc. — o nome sozinho dá `resourceNotFound`.
- `for anim in availableAnimations { … .repeat() }` toca **todas** as timelines (ex.: eletrosfera **e** núcleo) em loop.
- Eventos one-shot (fóton andando): **não** usar `.repeat()`; disparar por Behavior `On Tap` ou por código no momento certo.
- O **preview do RCP não faz loop** — validar sempre no **simulador/app**.

---

## 6 · Pendências

- [ ] Glúon e W: animação de **material** via Shader Graph (cor viajando / gradiente invertendo).
- [ ] Quarks, Z, Fóton: importar no projeto único e animar (receita do núcleo / twinkle).
- [ ] **Nêutron:** composição e animação de troca de cor — **o usuário monta no RCP**.
- [ ] Detalhes do **protótipo de alta fidelidade 2D** — **[preencher]** (telas, navegação, componentes).
- [ ] Confirmar alvo: **visionOS** vs iOS/AR.

---

*Fim da especificação. Trate este documento como fonte única de verdade das decisões de design do QuantumCore.*
