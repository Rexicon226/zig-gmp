#!/bin/bash

TARGET=../../vendor/x86_64

cd ../gmp-6.3.0/mpn

m4 -DOPERATION_add_n add_n.asm > $TARGET/add_n_add.s
m4 -DOPERATION_sub_n add_n.asm > $TARGET/add_n_sub.s

m4 -DOPERATION_addlsh1_n addlsh1_n.asm > $TARGET/addlsh1_n_add.s
m4 -DOPERATION_rsblsh1_n addlsh1_n.asm > $TARGET/addlsh1_n_rsb.s

m4 -DOPERATION_addlsh2_n addlsh2_n.asm > $TARGET/addlsh2_n_add.s
m4 -DOPERATION_rsblsh2_n addlsh2_n.asm > $TARGET/addlsh2_n_rsb.s

m4 invert_limb.asm > $TARGET/invert_limb.s
m4 invert_limb_table.asm > $TARGET/invert_limb_table.s

m4 -DOPERATION_addlsh_n addlsh_n.asm > $TARGET/addlsh_n_add.s
m4 -DOPERATION_rsblsh_n addlsh_n.asm > $TARGET/addlsh_n_rsb.s

m4 -DOPERATION_rsh1add_n rsh1add_n.asm > $TARGET/rsh1add_n_add.s
m4 -DOPERATION_rsh1sub_n rsh1add_n.asm > $TARGET/rsh1add_n_sub.s

m4 mul_1.asm > $TARGET/mul_1.s
m4 mul_2.asm > $TARGET/mul_2.s
m4 mode1o.asm > $TARGET/mode1o.s
m4 sublsh1_n.asm > $TARGET/sublsh1_n.s
m4 sqr_diag_addlsh1.asm > $TARGET/sqr_diag_addlsh1.s