global rb_tree_init
global rb_tree_deinit
global rb_tree_clear
global rb_tree_find
global rb_tree_insert
global rb_tree_erase

extern aligned_alloc
extern free

; typedef int (*compare_func)(const void*, const void*);

; enum rb_color { red = 0, black = 1 }

; enum rb_direction { left = 0, right = 1 }

; struct rb_node {
;     rb_color color  [rb_node]
;     void* key       [rb_node+4]
;     reserved(4)     [rb_node+8]
;     rb_node* parent [rb_node+12]
;     rb_node* left   [rb_node+16]
;     rb_node* right  [rb_node+20]
;     padding(8)
; }

; struct rb_tree {
;     rb_node* root   [rb_tree]
;     rb_node* nil    [rb_tree+4]
;     int size        [rb_tree+8]
;     compare_func cf [rb_tree+12]
; }

; rb_tree_init(compare_func f) -> rb_tree*
rb_tree_init:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = rb_tree* tree
    sub esp, 4+4*4

    ; tree = aligned_alloc(16, sizeof(rb_tree));
    sub esp, 8
    push dword 16
    push dword 16
    call aligned_alloc
    add esp, 16
    mov [ebp-12], eax

    ; tree->nil = aligned_alloc(16, sizeof(rb_node));
    sub esp, 8
    push dword 32
    push dword 16
    call aligned_alloc
    add esp, 16
    mov edx, [ebp-12]
    mov [edx+4], eax

    ; tree->nil = {
    ;     color = rb_color::black
    ;     key = 0
    ;     parent = nullptr
    ;     left = nullptr
    ;     right = nullptr
    ; };
    pxor xmm0, xmm0
    movdqa [eax], xmm0
    movdqa [eax+16], xmm0
    mov dword [eax], 1

    ; Use if sse2 doesn't supported
    ; mov dword [eax], 1
    ; mov dword [eax+4], 0
    ; mov dword [eax+12], 0
    ; mov dword [eax+16], 0
    ; mov dword [eax+20], 0

    ; tree->root = tree->nil;
    mov [edx], eax

    ; tree->size = 0
    mov dword [edx+8], 0

    ; tree->cf = [para] f;
    mov ecx, [ebp-4]
    mov eax, [ebp-12]
    mov edx, [ecx]
    mov [eax+12], edx

    ; return tree;
    mov eax, [ebp-12]
    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; rb_tree_del_node(rb_tree* this, rb_node* node)
rb_tree_del_node:
    push ebp
    mov ebp, esp
    sub esp, 8

    ; if ([para] node->left != this->nil)
    mov edx, [ebp+12]
    mov eax, [edx+16]
    mov edx, [ebp+8]
    cmp eax, [edx+4]
    je $+0xf

    ; rb_tree_del_node(this, node->left);
    sub esp, 8
    push eax
    push edx
    call rb_tree_del_node
    add esp, 16

    ; if ([para] node->right != this->nil)
    mov edx, [ebp+12]
    mov eax, [edx+20]
    mov edx, [ebp+8]
    cmp eax, [edx+4]
    je $+0xf

    ; rb_tree_del_node(this, node->left);
    sub esp, 8
    push eax
    push edx
    call rb_tree_del_node
    add esp, 16

    ; free([para] node);
    sub esp, 12
    push dword [ebp+12]
    call free
    add esp, 16

    leave
    ret

; rb_tree_deinit(rb_tree* this)
rb_tree_deinit:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    sub esp, 4

    ; if (this->root != this->nil)
    mov edx, [ecx]
    mov eax, [edx]
    cmp eax, [edx+4]
    je $+0xf

    ; rb_tree_del_node(this, this->root);
    sub esp, 8
    push eax
    push edx
    call rb_tree_del_node
    add esp, 16

    ; free(this->nil); free(this);
    sub esp, 12
    mov ecx, [ebp-4]
    mov edx, [ecx]
    push edx
    sub esp, 12
    push dword [edx+4]
    call free
    add esp, 16
    call free
    add esp, 16

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; rb_tree_clear(rb_tree* this)
rb_tree_clear:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    sub esp, 4

    ; this->size = 0;
    mov edx, [ecx]
    mov dword [edx+8], 0

    ; rb_tree_del_node(this, this->root);
    sub esp, 8
    push dword [edx]
    push edx
    call rb_tree_del_node
    add esp, 16

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; NULL is returned if the key does not exist.
; rb_tree_find(rb_tree* this, const void* key) -> rb_node*
rb_tree_find:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = rb_node* c, [ebp-16] = rb_node* nil
    ; [ebp-20] = compare_func cf;
    sub esp, 4+4*4

    ; c = this->root;
    mov edx, [ecx]
    mov eax, [edx]
    mov [ebp-12], eax

    ; nil = this->nil;
    mov eax, [edx+4]
    mov [ebp-16], eax

    ; cf = this->cf;
    mov eax, [edx+12]
    mov [ebp-20], eax

    ; while (c != nil)
    jmp $+0x29

    ; if (cf([para] key, c->key) == 0) return c;
    sub esp, 8
    mov eax, [ebp-12]
    push dword [eax+4]
    mov ecx, [ebp-4]
    push dword [ecx+4]
    call dword [ebp-20]
    add esp, 16

    cmp eax, 0
    mov eax, [ebp-12]
    je $+0x16

    ; else c = cf([para] key, c->key) < 0 ? c->left : c->right;
    mov edx, [eax+16]
    cmovg edx, [eax+20]
    mov [ebp-12], edx

    mov eax, [ebp-12]
    cmp eax, [ebp-16]
    jne $-0x2d

    ; return nullptr;
    xor eax, eax

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; rb_tree_rotate(rb_tree* this, rb_node* node, rb_direction d)
rb_tree_rotate:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = rb_node* p, [ebp-16] = rb_node* gp
    ; [ebp-20] = rb_node* x, [ebp-24] = rb_node* n
    sub esp, 4+4*4

    ; n = [para] node;
    mov eax, [ecx+4]
    mov [ebp-24], eax

    ; p = n->parent;
    mov edx, [ebp-24]
    mov eax, [edx+12]
    mov [ebp-12], eax

    ; gp = p->parent;
    mov eax, [eax+12]
    mov [ebp-16], eax

    ; x = d == rb_direction::left ? n->left : n->right;
    mov eax, [edx+16]
    cmp dword [ecx+8], 0
    cmovne eax, [edx+20]
    mov [ebp-20], eax

    ; if (p == this->root)
    mov edx, [ecx]
    mov eax, [edx]
    cmp eax, [ebp-12]
    jne $+0x9

    ; this->root = n;
    mov eax, [ebp-24]
    mov [edx], eax

    jmp $+0x1e

    ; if (gp->left == p)
    mov edx, [ebp-16]
    mov eax, [edx+16]
    cmp eax, [ebp-12]
    jne $+0xa

    ; gp->left = n;
    mov eax, [ebp-24]
    mov [edx+16], eax

    jmp $+0xb

    ; gp->right = n;
    mov edx, [ebp-16]
    mov eax, [ebp-24]
    mov [edx+20], eax

    ; n->parent = gp;
    mov eax, [ebp-16]
    mov edx, [ebp-24]
    mov [edx+12], eax

    ; p->parent = n;
    mov eax, [ebp-12]
    mov [eax+12], edx

    ; d == rb_direction::left ? n->left : n->right = p;
    cmp dword [ecx+8], 0
    lea eax, [edx+16]
    lea edx, [edx+20]
    cmovne eax, edx
    mov edx, [ebp-12]
    mov [eax], edx

    ; x->parent = p;
    mov edx, [ebp-20]
    mov eax, [ebp-12]
    mov [edx+12], eax

    ; d == rb_direction::left ? p->right : p->left = x;
    cmp dword [ecx+8], 0
    mov edx, [ebp-12]
    lea eax, [edx+16]
    lea edx, [edx+20]
    cmove eax, edx
    mov edx, [ebp-20]
    mov [eax], edx

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; rb_tree_xchg_color(rb_node* a, rb_node* b)
rb_tree_xchg_color:
    push ebp
    mov ebp, esp
    sub esp, 8

    mov eax, [ebp+8]
    mov edx, [ebp+12]

    mov ecx, [eax]
    xchg ecx, [edx]
    mov [eax], ecx

    leave
    ret

; rb_tree_newfix(rb_tree* this, rb_node* node)
rb_tree_newfix:
    push ebp
    mov ebp, esp
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = rb_node* p, [ebp-16] = rb_node* gp
    ; [ebp-20] = rb_node* u, [ebp-24] rb_node* n
    sub esp, 8+4*4

    ; n = [para] node;
    mov edx, [ebp+12]
    mov [ebp-24], edx

    ; p = n->parent;
    mov eax, [edx+12]
    mov [ebp-12], eax

    ; gp = p->parent;
    mov edx, [eax+12]
    mov [ebp-16], edx

    ; if (n == this->root)
    mov edx, [ebp+8]
    mov edx, [edx]
    mov eax, [ebp+12]
    cmp eax, edx
    jne $+0xd

    ; n->color = rb_color::black;
    mov dword [eax], 1

    ; return;
    jmp $+0x137

    ; if (p->color == rb_color::black) return;
    mov edx, [ebp-12]
    cmp dword [edx], 1
    je $+0x12c

    ; u = (gp->left == p ? gp->right : gp->left);
    mov edx, [ebp-16]
    mov eax, [ebp-12]
    cmp eax, [edx+16]
    mov eax, [edx+16]
    cmove eax, [edx+20]
    mov [ebp-20], eax

    ; if (u->color == rb_color::red)
    mov edx, [ebp-20]
    cmp dword [edx], 0
    jne $+0x31

    ; p->color = rb_color::black;
    mov edx, [ebp-12]
    mov dword [edx], 1

    ; u->color = rb_color::black;
    mov edx, [ebp-20]
    mov dword [edx], 1

    ; gp->color = rb_color::red;
    mov edx, [ebp-16]
    mov dword [edx], 0

    ; rb_tree_newfix(this, gp);
    sub esp, 8
    push edx
    push dword [ebp+8]
    call rb_tree_newfix
    add esp, 16

    ; return;
    jmp $+0xe1

    ; if (gp->left == p)
    mov edx, [ebp-16]
    mov eax, [edx+16]
    cmp eax, [ebp-12]
    jne $+0x6c

    ; if (p->left == n)
    mov edx, [ebp-12]
    mov eax, [edx+16]
    cmp eax, [ebp-24]
    jne $+0x2a

    ; rb_tree_rotate(this, p, rb_direction::right);
    sub esp, 4
    push dword 1
    push dword edx
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 16

    ; rb_tree_xchg_color(p, p->right);
    sub esp, 8
    mov edx, [ebp-12]
    push dword [edx+20]
    push edx
    call rb_tree_xchg_color
    add esp, 16

    jmp $+0xa3

    ; rb_tree_rotate(this, n, rb_direction::left);
    sub esp, 4
    push dword 0
    push dword [ebp-24]
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 12

    ; rb_tree_rotate(this, n, rb_direction::right);
    push dword 1
    push dword [ebp-24]
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 16

    ; rb_tree_xchg_color(n, n->right);
    sub esp, 8
    mov edx, [ebp-24]
    push dword [edx+20]
    push edx
    call rb_tree_xchg_color
    add esp, 16

    jmp $+0x69

    ; if (p->left == n)
    mov edx, [ebp-12]
    mov eax, [edx+16]
    cmp eax, [ebp-24]
    jne $+0x39

    ; rb_tree_rotate(this, n, rb_direction::right);
    sub esp, 4
    push dword 1
    push dword [ebp-24]
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 12

    ; rb_tree_rotate(this, n, rb_direction::left);
    push dword 0
    push dword [ebp-24]
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 16

    ; rb_tree_xchg_color(n, n->left);
    sub esp, 8
    mov edx, [ebp-24]
    push dword [edx+16]
    push edx
    call rb_tree_xchg_color
    add esp, 16

    jmp $+0x27

    ; rb_tree_rotate(this, p, rb_direction::left);
    sub esp, 4
    push dword 0
    push dword [ebp-12]
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 16

    ; rb_tree_xchg_color(p, p->left);
    sub esp, 8
    mov edx, [ebp-12]
    push dword [edx+16]
    push edx
    call rb_tree_xchg_color
    add esp, 16

    leave
    ret

; rb_tree_delfix(rb_tree* this, rb_node* pr, rb_direction d)
rb_tree_delfix:
    push ebp
    mov ebp, esp
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = rb_node* s, [ebp-16] = rb_node* n, [ebp-20] = rb_node* d
    sub esp, 8+4*4

    ; eax = [para] d == rb_direction::left ? [para] pr->left : [para] pr->right;
    mov edx, [ebp+12]
    cmp dword [ebp+16], 0
    mov eax, [edx+16]
    cmovne eax, [edx+20]

    ; if (eax->color == rb_color::red)
    cmp dword [eax], 0
    jne $+0xd

    ; eax->color = rb_color::black;
    mov dword [eax], 1

    ; return;
    jmp $+0x1b6

    ; s = [para] d == rb_direction::left ? [para] pr->right : [para] pr->left;
    mov edx, [ebp+12]
    cmp dword [ebp+16], 0
    mov eax, [edx+16]
    cmove eax, [edx+20]
    mov [ebp-12], eax

    ; if (s->color == rb_color::red)
    cmp dword [eax], 0
    jne $+0x3e

    ; rb_tree_rotate(this, s, [para] d);
    sub esp, 4
    push dword [ebp+16]
    push eax
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 16

    ; rb_tree_xchg_color(s, [para] pr);
    sub esp, 8
    push dword [ebp+12]
    push dword [ebp-12]
    call rb_tree_xchg_color
    add esp, 16

    ; rb_tree_delfix(this, [para] pr, [para] d);
    sub esp, 4
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call rb_tree_delfix
    add esp, 16

    ; return;
    jmp $+0x164

    ; n = [para] d == rb_direction::left ? s->left : s->right;
    cmp dword [ebp+16], 0
    mov edx, [ebp-12]
    mov eax, [edx+16]
    cmovne eax, [edx+20]
    mov [ebp-16], eax

    ; d = [para] d == rb_direction::left ? s->right : s->left;
    mov eax, [edx+16]
    cmove eax, [edx+20]
    mov [ebp-20], eax

    ; if (
    ;     [para] d == rb_direction::left &&
    ;     n->color == rb_color::red &&
    ;     d->color == rb_color::black
    ; )
    jne $+0x4f

    mov eax, [ebp-16]
    cmp dword [eax], 0
    jne $+0x47

    mov eax, [ebp-20]
    cmp dword [eax], 1
    jne $+0x3f

    ; rb_tree_rotate(this, n, rb_direction::right);
    sub esp, 4
    push dword 1
    push dword [ebp-16]
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 16

    ; rb_tree_xchg_color(s, n);
    sub esp, 8
    push dword [ebp-16]
    push dword [ebp-12]
    call rb_tree_xchg_color
    add esp, 16

    ; rb_tree_delfix(this, [para] pr, [para] d);
    sub esp, 4
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call rb_tree_delfix
    add esp, 16

    ; return;
    jmp $+0xfa

    ; if ([para] d == rb_direction::left && d->color == rb_color::red)
    cmp dword [ebp+16], 0
    jne $+0x3c

    mov eax, [ebp-20]
    cmp dword [eax], 0
    jne $+0x34

    ; rb_tree_rotate(this, s, rb_direction::left);
    sub esp, 4
    push dword 0
    push dword [ebp-12]
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 16

    ; rb_tree_xchg_color(s, [para] pr);
    sub esp, 8
    push dword [ebp+12]
    push dword [ebp-12]
    call rb_tree_xchg_color
    add esp, 16

    ; d->color = rb_color::black;
    mov eax, [ebp-20]
    mov dword [eax], 1

    ; return;
    jmp $+0xba

    ; if (n->color == rb_color::red && d->color == rb_color::black)
    mov eax, [ebp-16]
    cmp dword [eax], 0
    jne $+0x44

    mov eax, [ebp-20]
    cmp dword [eax], 1
    jne $+0x3c

    ; rb_tree_rotate(this, n, rb_direction::left);
    sub esp, 4
    push dword 0
    push dword [ebp-16]
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 16

    ; rb_tree_xchg_color(s, n);
    sub esp, 8
    push dword [ebp-16]
    push dword [ebp-12]
    call rb_tree_xchg_color
    add esp, 16

    ; rb_tree_delfix(this, [para] pr, [para] d);
    sub esp, 4
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call rb_tree_delfix
    add esp, 16

    ; return;
    jmp $+0x6d

    ; if (d->color == rb_color::red)
    mov eax, [ebp-20]
    cmp dword [eax], 0
    jne $+0x31

    ; rb_tree_rotate(this, s, rb_direction::right);
    sub esp, 4
    push dword 1
    push dword [ebp-12]
    push dword [ebp+8]
    call rb_tree_rotate
    add esp, 16

    ; rb_tree_xchg_color(s, [para] pr);
    sub esp, 8
    push dword [ebp+12]
    push dword [ebp-12]
    call rb_tree_xchg_color
    add esp, 16

    ; d->color = rb_color::black;
    mov eax, [ebp-20]
    mov dword [eax], 1

    ; return;
    jmp $+0x36

    ; s->color = rb_color::red;
    mov eax, [ebp-12]
    mov dword [eax], 0

    ; if ([para] pr != this->root)
    mov edx, [ebp+8]
    mov eax, [edx]
    cmp [ebp+12], eax
    je $+0x23

    ; rb_tree_delfix(this,
    ;     [para] pr->parent,
    ;     [para] pr->parent->left == [para] pr ?
    ;         rb_direction::left : rb_direction::right
    ; );
    sub esp, 4
    mov edx, [ebp+12]
    mov eax, [edx+12]
    cmp [eax+16], edx
    setne al
    movzx eax, al
    push eax
    push dword [edx+12]
    push dword [ebp+8]
    call rb_tree_delfix
    add esp, 16

    leave
    ret

; return value = pair<rb_node*, bool> {
;     rb_node* (eax); // rb_node pointer to the inserted key.
;     bool     (edx); // Whether key was inserted.
; rb_tree_insert(rb_tree* this, const void* key) -> pair<rb_node*, bool>
rb_tree_insert:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = rb_node* n, [ebp-16] = rb_node* c, [ebp-20] = rb_node* nil
    ; [ebp-24] = compare_func fc
    sub esp, 4+4*4

    ; eax = rb_tree_find(this, key);
    sub esp, 8
    push dword [ecx+4]
    push dword [ecx]
    call rb_tree_find
    add esp, 16

    ; if (eax) return { eax, 0 };
    test eax, eax
    mov edx, 0
    jnz $+0xdc

    ; this->size++;
    mov ecx, [ebp-4]
    mov edx, [ecx]
    inc dword [edx+8]

    ; nil = this->nil;
    mov ecx, [ebp-4]
    mov edx, [ecx]
    mov eax, [edx+4]
    mov [ebp-20], eax

    ; fc = this->fc;
    mov eax, [edx+12]
    mov [ebp-24], eax

    ; n = aligned_alloc(16, sizeof(rb_node));
    sub esp, 8
    push dword 32
    push dword 16
    call aligned_alloc
    add esp, 16
    mov [ebp-12], eax

    ; n->key = [para] key;
    mov ecx, [ebp-4]
    mov edx, eax
    mov eax, [ecx+4]
    mov [edx+4], eax

    ; n->color = rb_color::red;
    mov dword [edx], 0

    ; n->parent = n->left = n->right = nil;
    mov eax, [ebp-20]
    mov [edx+12], eax
    mov [edx+16], eax
    mov [edx+20], eax

    ; c = this->root
    mov edx, [ecx]
    mov eax, [edx]
    mov [ebp-16], eax

    ; while (c != nil)
    jmp $+0x4c

    ; if (cf([para] key, c->key) < 0)
    sub esp, 8
    mov edx, [ebp-16]
    push dword [edx+4]
    mov ecx, [ebp-4]
    mov edx, [ecx]
    push dword [ecx+4]
    call dword [ebp-24]
    add esp, 16
    cmp eax, 0
    jge $+0x1a

    ; if (c->left == nil)
    mov edx, [ebp-16]
    mov eax, [edx+16]
    cmp eax, [ebp-20]
    jne $+0xa

    ; c->left = n;
    mov eax, [ebp-12]
    mov [edx+16], eax

    ; break;
    jmp $+0x25

    ; c = c->left;
    mov [ebp-16], eax

    jmp $+0x18

    ; if (c->right == nil)
    mov edx, [ebp-16]
    mov eax, [edx+20]
    cmp eax, [ebp-20]
    jne $+0xa

    ; c->right = n;
    mov eax, [ebp-12]
    mov [edx+20], eax

    ; break;
    jmp $+0xd

    ; c = c->right;
    mov [ebp-16], eax

    mov eax, [ebp-16]
    cmp eax, [ebp-20]
    jne $-0x50

    ; n->parent = c;
    mov edx, [ebp-12]
    mov eax, [ebp-16]
    mov [edx+12], eax

    ; if (c == nil)
    cmp eax, [ebp-20]
    jne $+0xc

    ; this->root = n;
    mov ecx, [ebp-4]
    mov edx, [ecx]
    mov eax, [ebp-12]
    mov [edx], eax

    ; rb_tree_newfix(this, n);
    sub esp, 8
    push dword [ebp-12]
    mov ecx, [ebp-4]
    push dword [ecx]
    call rb_tree_newfix
    add esp, 16

    mov eax, [ebp-12]
    mov edx, 1

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; rb_tree_next(rb_tree* this, rb_node* n) -> rb_node*
rb_tree_next:
    push ebp
    mov ebp, esp
    ; [ebp-12] = rb_node* c, [ebp-16] = rb_node* nil
    sub esp, 8+4*4

    ; c = [para] n->right;
    mov edx, [ebp+12]
    mov eax, [edx+20]
    mov [ebp-12], eax

    ; nil = this->nil;
    mov edx, [ebp+8]
    mov eax, [edx+4]
    mov [ebp-16], eax

    ; if (c == nil)
    cmp [ebp-12], eax
    jne $+0x18

    ; c = [para] n;
    mov eax, [ebp+12]
    mov [ebp-12], eax

    ; while (true)
    ; if (c->parent->right != c) return c->parent;
    mov edx, [ebp-12]
    mov eax, [edx+12]
    cmp [eax+20], edx
    jne $+0x20

    ; c = c->parent;
    mov [ebp-12], eax

    jmp $-0xe

    ; while (c->left != nil)
    jmp $+0xb
    
    ; c = c->left;
    mov edx, [ebp-12]
    mov eax, [edx+16]
    mov [ebp-12], eax

    mov edx, [ebp-12]
    mov eax, [edx+16]
    cmp eax, [ebp-16]
    jne $-0x12

    ; return c;
    mov eax, [ebp-12]

    leave
    ret

; return value = bool // Whether a key was erased.
; rb_tree_erase(rb_tree* this, const void* key) -> bool
rb_tree_erase:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-40]
    ; [ebp-12] = rb_node* d, [ebp-16] = rb_node* r
    ; [ebp-20] = rb_node* p, [ebp-24] = rb_node* nil
    ; [ebp-28] = bool(4) rb, [ebp-32] = rb_direction rl
    sub esp, 4+4*8

    ; nil = this->nil;
    mov edx, [ecx]
    mov eax, [edx+4]
    mov [ebp-24], eax

    ; d = rb_tree_find(this, [para] key);
    sub esp, 8
    push dword [ecx+4]
    push dword [ecx]
    call rb_tree_find
    add esp, 16
    mov [ebp-12], eax

    ; if (d == nullptr) return 0;
    test eax, eax
    jz $+0xfa

    ; this->size--;
    mov ecx, [ebp-4]
    mov edx, [ecx]
    dec dword [edx+8]

    ; if (d->left != nil && d->right != nil)
    mov edx, eax
    mov eax, [edx+16]
    cmp eax, [ebp-24]
    je $+0x33

    mov eax, [edx+20]
    cmp eax, [ebp-24]
    je $+0x2b

    ; r = rb_tree_next(this, d);
    sub esp, 8
    push dword [ebp-12]
    mov ecx, [ebp-4]
    push dword [ecx]
    call rb_tree_next
    add esp, 16
    mov [ebp-16], eax

    ; p = r->right;
    mov edx, eax
    mov eax, [edx+20]
    mov [ebp-20], eax

    ; d->key = r->key;
    mov eax, [edx+4]
    mov edx, [ebp-12]
    mov [edx+4], eax

    jmp $+0x18

    ; r = d;
    mov eax, [ebp-12]
    mov [ebp-16], eax

    ; p = r->right != nil ? r->right : r->left;
    mov edx, [ebp-16]
    mov eax, [edx+20]
    cmp eax, [ebp-24]
    cmove eax, [edx+16]
    mov [ebp-20], eax

    ; if (r == this->root)
    mov ecx, [ebp-4]
    mov edx, [ecx]
    mov eax, [edx]
    cmp [ebp-16], eax
    jne $+0x22

    ; this->root = p;
    mov eax, [ebp-20]
    mov [edx], eax

    ; this->root->color = rb_color::black;
    mov dword [eax], 1

    ; free(r);
    sub esp, 12
    push dword [ebp-16]
    call free
    add esp, 16

    ; return 1;
    mov eax, 1
    jmp $+0x71

    ; rb = r->color;
    mov edx, [ebp-16]
    mov eax, [edx]
    mov [ebp-28], eax

    ; rl = r->parent->left == r ? rb_direction::left : rb_direction::right;
    mov eax, [edx+12]
    mov eax, [eax+16]
    cmp eax, edx
    setne al
    movzx eax, al
    mov [ebp-32], eax

    ; (rl == rb_direction::left ? r->parent->left : r->parent->right) = p;
    cmp dword [ebp-32], 0
    mov edx, [edx+12]
    lea eax, [edx+16]
    lea edx, [edx+20]
    cmovne eax, edx
    mov edx, [ebp-20]
    mov [eax], edx

    ; p->parent = r->parent;
    mov edx, [ebp-16]
    mov eax, [edx+12]
    mov edx, [ebp-20]
    mov [edx+12], eax

    ; /* save r->parent */
    ; free(r);
    sub esp, 8
    mov edx, [ebp-16]
    push dword [edx+12]
    push edx
    call free
    add esp, 4
    ; /* restore to edx */
    pop edx
    add esp, 8

    ; if (rb)
    cmp dword [ebp-28], 0
    jz $+0x1b

    ; rb_tree_delfix(this, edx, rl);
    sub esp, 4
    push dword [ebp-32]
    push edx
    mov ecx, [ebp-4]
    push dword [ecx]
    call rb_tree_delfix
    add esp, 16

    ; return 1;
    mov eax, 1

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret