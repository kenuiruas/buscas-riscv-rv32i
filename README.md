# Busca binária e busca sequencial em Assembly RISC-V

**Universidade Católica de Santos**  
**Curso:** Ciência da Computação  
**Disciplina:** Arquitetura de Computadores  
**Professor:** Walter S. Oliveira  
**Integrante:** Kenui Ruas - 6251479

## 1. Objetivo

O objetivo deste projeto é comparar duas formas de buscar um número em um vetor ordenado: a busca sequencial e a busca binária. A ideia é observar não só se os algoritmos encontram o valor correto, mas também quantos elementos precisam consultar e como isso afeta a execução do programa no processador.

Os dois programas foram escritos em Assembly RISC-V, utilizando o conjunto de instruções RV32I. Para manter a comparação justa, ambos utilizam o mesmo vetor, recebem os mesmos argumentos e apresentam o resultado no console.

## 2. Funcionamento

A busca sequencial começa na primeira posição e percorre o vetor até encontrar o número procurado. Como o vetor está em ordem crescente, a busca também termina caso encontre um elemento maior que o alvo.

A busca binária começa pelo elemento central. Se o valor procurado for menor, a busca continua na metade esquerda; se for maior, continua na metade direita. Esse processo se repete até encontrar o número ou até não restarem elementos.

O vetor utilizado contém 16 números inteiros:

```text
[2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32]
```

A entrada é definida na seção `.data` de cada arquivo. A saída contém o índice do elemento encontrado, começando em zero, e a quantidade de elementos consultados durante a busca. Quando o valor não é encontrado, o índice retornado é -1.

Neste trabalho, o contador de comparações representa quantos elementos do vetor foram consultados, e não a quantidade de instruções de desvio ou de testes de condição executados pela CPU.

## 3. Implementação

Cada arquivo tem três partes principais:

- `main`: chama a rotina de execução, mostra os resultados no console e encerra o programa.
- `executar_busca`: carrega os argumentos, chama `buscar` e guarda o índice e o contador na memória.
- `buscar`: implementa o algoritmo de busca correspondente ao arquivo e devolve os resultados.

### Registradores e pilha

| Registrador | Função |
| --- | --- |
| `a0` | Endereço inicial do vetor; no retorno, índice encontrado |
| `a1` | Quantidade de elementos; no retorno, contador de comparações |
| `a2` | Valor procurado |
| `a7` | Código da chamada de sistema (`ecall`) |
| `t0` a `t5` | Índices, limites, contador, endereços e valores temporários |
| `s0` | Endereço da variável de resultado na rotina `executar_busca` |
| `ra` | Endereço de retorno de uma sub-rotina |
| `sp` | Ponteiro da pilha |

A chamada de sub-rotina é feita com `jal ra, rotulo` e o retorno com `jalr zero, 0(ra)`. Como `executar_busca` chama outra rotina, reserva 16 bytes na pilha e salva `ra` e `s0` antes da chamada. Os dois registradores são recuperados antes do retorno e o ponteiro da pilha volta à posição anterior. A rotina `buscar` não chama outras rotinas e utiliza apenas registradores temporários e de argumentos, por isso não precisa criar outro quadro na pilha.

### Organização da memória

Os endereços abaixo são relativos ao início de `vetor`, de modo que independem do endereço inicial da seção de dados escolhido pelo simulador.

| Rótulo | Deslocamento (bytes) | Conteúdo |
| --- | ---: | --- |
| `vetor` | 0 a 63 | 16 inteiros de 32 bits |
| `quantidade` | 64 | Tamanho do vetor |
| `alvo` | 68 | Número que será buscado |
| `indice` | 72 | Índice encontrado ou -1 |
| `comparacoes` | 76 | Total de elementos consultados |
| Mensagens | A partir de 80 | Textos do console terminados em nulo |

Na busca sequencial, o endereço é incrementado em quatro bytes a cada avanço. Na busca binária, `slli` desloca o índice em dois bits para calcular o deslocamento em bytes, e `srli` permite dividir a diferença entre os limites por dois. Assim, não é necessário utilizar instruções de multiplicação ou divisão da extensão M. A pseudoinstrução `la` é expandida pelo montador em instruções da arquitetura base.

## 4. Como executar no Ripes

1. Abra o [Ripes](https://ripes.me/) no navegador ou instale a versão disponível no [repositório oficial](https://github.com/mortbopet/Ripes/releases).
2. Na seleção de processador, escolha o modelo RISC-V de 32 bits **5-stage processor**, com as extensões M e C desmarcadas, se disponíveis. Mantenha a mesma configuração nos dois programas.
3. Na aba **Editor**, abra ou cole o conteúdo de `busca_sequencial.s`.
4. Confira que a variável `alvo` está com o valor 16. Não é necessário configurar periféricos externos.
5. Abra a aba **Processor**, clique em **Reset** e depois em **Run**. A execução termina com a chamada de sistema de saída.
6. Verifique o console e as estatísticas de execução (instruções, ciclos e CPI).
7. Repita o procedimento com `busca_binaria.s`.
8. Para os demais testes, altere somente o valor de `alvo` nos dois arquivos, reinicie o processador e execute novamente. Ao terminar, restaure o valor 16 nos arquivos originais.

### Exemplo de entrada e saída

Entrada nos dois arquivos: `alvo: .word 16`

Busca sequencial:

```text
Indice: 7
Comparacoes: 8
```

Busca binária:

```text
Indice: 7
Comparacoes: 1
```

O valor 16 ocupa a oitava posição do vetor, que corresponde ao índice 7. Na busca binária, ele é justamente o primeiro elemento central consultado.

## 5. Testes e resultados

### Validação funcional

Os arquivos foram montados para RV32I e executados em um interpretador local das instruções utilizadas. Os resultados completos dessa verificação estão em [evidencias/validacao-local.txt](evidencias/validacao-local.txt). A tabela abaixo resume quatro casos com o vetor completo.

| Alvo | Caso | Índice | Comparações: sequencial | Comparações: binária |
| ---: | --- | ---: | ---: | ---: |
| 2 | Primeiro elemento | 0 | 1 | 4 |
| 16 | Elemento central | 7 | 8 | 1 |
| 32 | Último elemento | 15 | 16 | 5 |
| 17 | Valor ausente | -1 | 9 | 4 |

Também foram verificados valores fora dos limites do vetor, um vetor vazio e um vetor de apenas um elemento. Os dois algoritmos retornaram os resultados esperados nos 16 testes locais.

### Desempenho no Ripes

Modelo de processador: 5 estágios, RV32I.

As métricas abaixo devem ser preenchidas a partir de execuções no Ripes. A contagem deve abranger o programa completo, incluindo preparação dos dados e saída no console, que são iguais nos dois arquivos. O CPI corresponde ao número de ciclos dividido pelo número de instruções executadas, conforme a contagem do simulador.

| Alvo | Algoritmo | Instruções | Ciclos | CPI |
| ---: | --- | ---: | ---: | ---: |
| 2 | Sequencial | 58 | 84 | 1,45 |
| 2 | Binária | 99 | 131 | 1,32 |
| 16 | Sequencial | 114 | 154 | 1,35 |
| 16 | Binária | 63 | 89 | 1,41 |
| 32 | Sequencial | 178 | 234 | 1,31 |
| 32 | Binária | 111 | 153 | 1,38 |
| 17 | Sequencial | 123 | 165 | 1,34 |
| 17 | Binária | 103 | 139 | 1,35 |

As capturas do simulador devem ser colocadas na pasta `evidencias/` junto com a validação funcional.

## 6. Análise dos resultados

Os testes funcionais mostram que a busca sequencial é vantajosa quando o alvo está no início do vetor. Para o valor 2, ela consulta apenas um elemento, enquanto a busca binária consulta quatro. Já no último elemento, a busca binária consulta cinco posições e a sequencial precisa percorrer todas as 16. Quando o número 17 não está presente, a busca sequencial termina ao consultar o valor 18, enquanto a busca binária elimina partes do vetor até encerrar a procura.

A busca sequencial possui complexidade O(n) no pior caso, enquanto a binária possui complexidade O(log n). A busca binária, entretanto, utiliza mais instruções por iteração para calcular a posição central e atualizar os limites. Por isso, uma redução no número de elementos consultados não representa necessariamente uma redução proporcional no total de instruções ou ciclos.

Na arquitetura RV32I, as duas versões utilizam instruções de carga (`lw`) para ler os elementos e desvios condicionais (`beq`, `blt` e `bge`) para controlar o fluxo. A quantidade de desvios e as dependências entre instruções podem afetar o desempenho de um processador com pipeline. O resultado em ciclos também depende do modelo de CPU escolhido no Ripes.

Ambas as versões são iterativas e usam uma quantidade constante de memória auxiliar. A rotina de execução ocupa 16 bytes de pilha em ambos os programas. A busca binária tem a vantagem de reduzir o número de acessos ao vetor em muitos casos, mas exige que ele já esteja ordenado. O custo de ordenar o vetor não faz parte desta comparação.

## 7. Conclusão

A implementação permitiu observar como dois algoritmos que resolvem o mesmo problema podem ter comportamentos diferentes no processador. A busca sequencial é simples e funciona bem para valores próximos do começo do vetor. A busca binária é mais adequada quando o vetor está ordenado e é necessário reduzir a quantidade de elementos consultados, especialmente à medida que o tamanho do vetor aumenta.

## Referências

- Material e enunciado do projeto da disciplina de Arquiteturas de Computadores.
- [Documentação do Ripes](https://github.com/mortbopet/Ripes/blob/master/docs/introduction.md).
- [Chamadas de sistema do Ripes](https://github.com/mortbopet/Ripes/blob/master/docs/ecalls.md).
