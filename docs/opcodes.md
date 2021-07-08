
# Opcodes
## values opcodes
opcode | symbol | stack changes | comment
---| --- | --- | ---
0  | int |  -- X  | the next 32 bits = 4 bytes are put on the stack as a single binary.
2  | binary |  N -- L  | the next N * 8 bits are put on the stack as a single binary.
3  | int1 |  -- X  | the next 8 bits = 1 bytes are put on the stack as a 4-byte binary, which is our representation of integers.
4  | int2 |  -- X  | the next 16 bits = 2 bytes are put on the stack as a 4-byte binary.



## other opcodes
opcode | symbol | stack changes | comment
---| ---   | --- | ---
10 | print | ( Y -- X ) | prints the top element on stack
11 | return |    | code stops execution here. Whatever is on top of the stack is the final state.
12 | nop | ( -- ) | does nothing.
13 | fail | ( -- ) | throws an error. Invalid transaction.


## stack opcodes
opcode | symbol | stack changes | comment
--- | --- | --- | ---
20 | drop | X --     | will remove the top element on stack
21 | dup  | X -- X X | duplicates the top element of the stack
22 | swap | A B -- B A| swaps the top two element of the stack
23 | tuck | a b c -- c a b |
24 | rot  | a b c -- b c a |
25 | 2dup | a b -- a b a b |
26 | tuckn| X N -- | inserts X N-deeper into the stack.
27 | pickn| N -- X | grabs X from N-deep into the stack.


## r-stack opcodes
opcode | symbol | stack changes | comment
---| ---| ---   | ---
30 | >r | V --  |
31 | r> | -- V  | moves from return to stack
32 | r@ | -- V  | copies from return to stack


## crypto opcodes
opcode | symbol | stack changes | comment
--- | --- | --- | ---
40 | hash | X -- <<Bytes:256>>  |

## arithmetic opcodes
Note about arithmetic opcodes:
they only works with 4-byte integers. Results are 4-byte integers. 32-bits. The integers are encoded so that FFFFFFFF is the highest integer and 00000000 is the lowest.

opcode | symbol | stack changes | comment
--- | --- | --- | ---
50 | + |  X Y -- Z |
51  |- |  X Y -- Z |
52 | * |  X Y -- Z |
53 | / |  X Y -- Z |
54 | > |  X Y -- X Y true/false |
55 | < |  X Y -- X Y true/false |
56 | ^ |  X Y -- Z | exponentiation |
57 | rem| A B -- C | only works for integers. "
58 | == | X Y -- X Y true/false |
58 | =2 | X Y -- true/false |


## conditions opcodes

opcode | symbol | stack changes | comment
--- | --- | --- | ---
70 | if   |  | conditional statement
71 | else |  | part of an switch conditional statement
72 | then |  | part of switch conditional statement.


## logic opcodes
opcode | symbol | stack changes | comment
--- | --- | --- | ---
80 | not | true/false -- false/true |
81 | and | true/false true/false -- true/false | false is 0, true is any non-zero byte.
82 | or  | true/false true/false -- true/false |
83 | xor | true/false true/false -- true/false |
84 | band|  4 12 -- 4 | if inputed binaries are different length, it returns a binary of the longer length
85 | bor | 4 8 -- 12  |
86 | bxor| 4 12 -- 8  |


## check state opcodes

opcode | symbol | stack changes | comment
--- | --- | --- | ---
90 | stack_size | -- Size |
94 | gas | -- X |
95 | ram | -- X | tells how much space is left in ram.
97 | many_vars | -- X | how many variables are defined.
98 | many_vars | -- X | how many functions are defined.


## function opcodes
opcode | symbol | stack changes | comment
--- | --- | --- | ---
110 | : |  | this starts the function declaration.
111 | ; |  |This symbol ends a function declaration. example : square dup * ;
112 | recurse |  | crash. this word should only be used in the definition of a word.
113 | call |  | Use the binary at the top of the stack to look in our hashtable of defined words. If it exists call the code, otherwise crash.
114 | def |  |This symbol ends a function declaration. Leaves the hash of the new function on the top of the stack.


## variables opcodes
opcode | symbol | stack changes | comment
--- | --- | --- | ---
120 | !   | X -- Y |  only stores 32-bit integers
121 | @   | Y -- X |


## lists opcodes
opcode | symbol | stack changes | comment
--- | --- | --- | ---
130 | cons|  X Y -- [X\|Y] |
131 | car |  [X\|Y] -- X Y |
132 | nil |  -- []        | puts an empty list on the stack
134 | ++  |  X Y -- Z     | appends 2 lists or 2 binaries. Cannot append a list to a binary. Also works on pairs of lists.
135 | split |  N Binary -- BinaryA BinaryB  | Binary A has N*8 many bits. BinaryA appended to BinaryB makes Binary.
136 | reverse |  	 F -- G | only works on lists
137 | is_list | L -- L B | checks if the thing on the top of the stack is a list or not. Does not drop it.

## numbers 0-35
opcode | symbol | stack changes | comment
--- | --- | --- | ---
140 | 0 | -- 0 |
141 | 1 | -- 1 |
175 | 35 | -- 35 |

# memory
opcode | symbol | stack changes | comment
--- | --- | --- | ---
181 | !1 | X Location -- | stores a bit of memory
182 | @1 | Location -- | recalls a bit of memory
183 | !8 | X Location -- | stores a byte of memory
184 | @8 | Location -- | recalls a byte of memory
185 | !32 | X Location -- | stores 32 bytes of memory
186 | @32 | Location -- | recalls 32 bytes of memory
187 | look | X Y -- [Food Species Direction Daytime] | access visual information for a location. Y can be 0, 1, or 2. X can be -2, -1, 0, 1, or 2.
188 | smell_animal | -- [species 32_byte_tag] | smells the animal on the tile in front of you
189 | smell_tile | -- [species age] | smells the tile in front of you. Who was there and how long ago.
190 | smell_food | -- 1/0 | smells the tile you are standing on to see if there is food.
191 | pain_front | -- 1/0 | checks if you feel pain from the front
192 | pain_left | -- 1/0 | checks if you feel pain from the left
193 | pain_right | -- 1/0 | checks if you feel pain from the right
194 | pain_back | -- 1/0 | checks if you feel pain from the back
195 | energy | -- E | checks how much energy you have left 
196 | health | -- H | checks how much health you have 
197 | time | -- T | checks the current time 
198 | random | -- 32_bytes_of_randomness 


The following are how comments work for the forth-like compiler.

* ( a open parenthesis starts a multi-line comment block.

* ) a closed parenthesis ends the comment.

* % a percent symbol comments out the rest of that line.




