# PinyinToneCycler

[Read in English](README.md)

Um script AHK simples para Windows que permite alternar entre os tons do pinyin durante a digitação, com um toque.

# Por que isto existe

A entrada padrão de chinês do Windows não tem uma boa solução para marcar os tons do pinyin. O macOS permite que o usuário toque na tecla Tab para alternar entre as marcas de tom da sílaba.

Embora o Windows tenha algumas alternativas, como o [PinyinTones](https://github.com/PinyinTones/PinyinTones), o uso ainda é trabalhoso, já que você precisa trocar o método de entrada só para o pinyin e depois voltar para o que estava usando antes.

Então este script traz para o Windows um método de atribuir tons parecido com o do macOS: digite a sílaba e toque em um atalho até o tom ficar certo.

# Instalação

1. Instale o [AutoHotkey v2](https://www.autohotkey.com/). O script precisa dele para rodar, e o AutoHotkey v1 não funciona.
2. Baixe o `PinyinToneCycler.ahk` e dê um duplo clique nele. Um ícone "H" aparece na bandeja do sistema.
3. Opcional: para iniciar junto com o Windows, marque **Start with Windows** nas configurações.

Dê um duplo clique no ícone da bandeja para abrir as configurações. Clique com o botão direito para pausar ou sair.

# Uso

Digite uma sílaba e pressione o atalho, que por padrão é **Alt + a tecla à esquerda do 1** (`'` no ABNT2, `` ` `` em um teclado americano). Cada toque passa para o tom seguinte:

```
ni → nī → ní → nǐ → nì → ni
```

Por padrão, o quinto toque remove a marca de tom, para o tom neutro.

- Para o ü, digite `v` ou `u:`. Tanto `lv` quanto `lu:` viram lǖ.
- A marca vai automaticamente na vogal correta: `hao` vira hāo, `liu` vira liū.
- Só a última sílaba muda. Em `nihao`, o tom vai em `hao`, então pressione o atalho depois de cada sílaba.
- Só funciona logo depois de digitar. Clicar, usar as setas ou trocar de janela cancela.

# Configurações

A interface do script é em inglês, então as opções aparecem com os nomes abaixo.

| Opção | O que faz |
| --- | --- |
| Cycle hotkey | O atalho que muda o tom. Precisa incluir Ctrl ou Alt, para não atrapalhar a digitação. |
| Pause hotkey | Opcional. Desliga e liga o script. |
| Type ü with | `v`, `u:`, qualquer um dos dois ou nenhum. Digitar um ü de verdade sempre funciona. |
| Tone order | Mova os tons para cima ou para baixo, ou desmarque um para pulá-lo. O primeiro toque nunca para em "No tone" (sem tom), já que a sílaba ainda não tem marca. |
| Start with Windows | Inicia o script quando você faz login. |
| Close button (X) | Fecha só a janela de configurações, deixando o script rodando na bandeja, ou encerra o script. |

As configurações ficam salvas em `%AppData%\PinyinToneCycler\settings.ini`.

# Privacidade

O script precisa observar o que você digita para saber o que acabou de ser digitado. Ele guarda no máximo as últimas 12 letras na memória e nunca as salva nem as envia para lugar nenhum.

# Licença

[AGPL-3.0](LICENSE).

# Aviso sobre IA

Sim, o script foi feito com IA. Estou aprendendo mandarim, não a linguagem de script do AHK, e só queria uma ferramenta rápida para resolver o que considero uma falha grave nas opções de entrada do Windows.
Ninguém perdeu uma encomenda nem foi demitido por causa disso, e também não estou cobrando nada. É um pequeno utilitário que eu queria para mim e, como funcionou bem o bastante, decidi compartilhar.
Se você odeia IA, fique à vontade para não usar. Não quero entrar em briga por causa disso.

# Aviso sobre contribuições

Pedi algo simples e li o script depois. Se eu ficar com medo de alguma coisa, posso encher o saco do robô eu mesmo, perguntando sobre cada detalhe. Não me responsabilizo pelo que acontecer na sua máquina (cláusula padrão da GPL), mas me responsabilizo por qualquer mudança de código feita na minha conta, e não quero revisar PRs de IA sem fim. Por isso decidi usar o velho sistema de honra: você é 100% responsável por qualquer issue ou PR que abrir, e também é responsável por qualquer funcionalidade que adicionar. Se não quiser dar manutenção, deixe no seu fork.

- Nada de PRs intermináveis de lixo gerado por IA
- Nada de PRs do tipo "mandei e sumi": assuma a responsabilidade
- Nada de PR só de robô, em que a IA também responde às discussões e nunca desiste
- Qualquer issue ou PR pode ser recusada sem aviso nem justificativa
- Contas que demonstrarem comportamento de "fábrica de lixo de IA", despejando porcaria no repositório só para deixar o perfil mais bonito no portfólio, serão expostas sem dó.

Então, se quiser adicionar algo:

- Crie uma issue com o bug ou a funcionalidade que quer pedir ou resolver
- Espere uma resposta dizendo se está dentro ou fora do escopo (isto é a solução para um problema simples, não um mega app faz-tudo de portfólio)
- Faça um fork e todos os testes.
- Escreva o PR À MÃO e, por favor, SEJA CONCISO.
- Espere uma resposta.
