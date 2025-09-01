const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gmp_dep = b.dependency("gmp", .{});

    const gmp = b.addLibrary(.{
        .linkage = .static,
        .name = "gmp",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(gmp);

    const gmp_header = b.addConfigHeader(.{
        .style = .{ .cmake = gmp_dep.path("gmp-h.in") },
        .include_path = "gmp.h",
    }, .{
        .__GMP_WITHIN_CONFIGURE = 1,
        .__GMP_EXTERN_INLINE = null,
        .HAVE_HOST_CPU_FAMILY_power = false,
        .HAVE_HOST_CPU_FAMILY_powerpc = false,
        .GMP_LIMB_BITS = 64,
        .GMP_NAIL_BITS = 0,
        .DEFN_LONG_LONG_LIMB = .@"#define _LONG_LONG_LIMB 1",
        .LIBGMP_DLL = 0,
        .CC = "zigcc",
        .CFLAGS = "",
    });
    gmp.addConfigHeader(gmp_header);
    gmp.installConfigHeader(gmp_header);

    const mparam_path = switch (target.result.cpu.arch) {
        .x86_64 => "mpn/x86_64/",
        .aarch64 => "mpn/arm64/",
        else => |t| std.debug.panic("TODO support {s}", .{@tagName(t)}),
    };
    gmp.addIncludePath(gmp_dep.path(mparam_path));

    const limb_bits = switch (target.result.cpu.arch) {
        .aarch64, .x86_64 => 64,
        else => |t| std.debug.panic("TODO support {s}", .{@tagName(t)}),
    };

    const header_files = b.addWriteFiles();
    gmp.addIncludePath(header_files.getDirectory());
    _ = header_files.addCopyFile(
        try genTable(b, gmp_dep, "gen-fib", "header", 0, limb_bits),
        "fib_table.h",
    );
    _ = header_files.addCopyFile(
        try genTable(b, gmp_dep, "gen-fac", null, 0, limb_bits),
        "fac_table.h",
    );
    _ = header_files.addCopyFile(
        try genTable(b, gmp_dep, "gen-sieve", null, null, limb_bits),
        "sieve_table.h",
    );
    _ = header_files.addCopyFile(
        try genTable(b, gmp_dep, "gen-bases", "header", 0, limb_bits),
        "mp_bases.h",
    );
    _ = header_files.addCopyFile(
        try genTable(b, gmp_dep, "gen-jacobitab", null, null, null),
        "jacobitab.h",
    );
    _ = header_files.addCopyFile(
        try genTable(b, gmp_dep, "gen-psqr", null, 0, limb_bits),
        "perfsqr.h",
    );
    _ = header_files.addCopyFile(
        try genTable(b, gmp_dep, "gen-trialdivtab", null, 8000, limb_bits),
        "trialdivtab.h",
    );

    gmp.linkLibC();
    gmp.linkLibCpp();
    gmp.addIncludePath(gmp_dep.path("."));

    const config = makeConfigHeader(b, gmp_dep, target);
    gmp.addConfigHeader(config);

    gmp.addCSourceFiles(.{
        .root = gmp_dep.path("."),
        .files = &.{
            "assert.c",
            "tal-reent.c",
            "memory.c",
            "errno.c",
            "mp_minv_tab.c",
            "mp_dv_tab.c",
            "mp_clz_tab.c",
            "printf/printf.c",
            "printf/doprnt.c",
            "printf/printffuns.c",
            "printf/doprnti.c",
            "printf/doprntf.c",
            "printf/asprintf.c",
            "printf/vasprintf.c",
            "printf/asprntffuns.c",
        },
        .flags = &.{"-DCOUNT_LEADING_ZEROS_NEED_CLZ_TAB"},
    });

    gmp.addCSourceFiles(.{
        .root = gmp_dep.path("mpz"),
        .files = &.{
            "mul_2exp.c",     "clear.c",      "init.c",
            "add_ui.c",       "realloc.c",    "tdiv_qr.c",
            "set_ui.c",       "set_si.c",     "sub_ui.c",
            "get_str.c",      "xor.c",        "tdiv_r_2exp.c",
            "tdiv_q_2exp.c",  "tdiv_q.c",     "tdiv_r.c",
            "sub.c",          "sizeinbase.c", "size.c",
            "set.c",          "scan0.c",      "scan1.c",
            "pow_ui.c",       "neg.c",        "mul.c",
            "ior.c",          "get_ui.c",     "get_si.c",
            "get_d.c",        "gcd.c",        "cmp_ui.c",
            "cmp_si.c",       "cmp.c",        "swap.c",
            "n_pow_ui.c",     "get_d.c",      "popcount.c",
            "mul_si.c",       "add.c",        "abs.c",
            "and.c",          "iset_si.c",    "getlimbn.c",
            "iset.c",         "mul_ui.c",     "fits_sint.c",
            "set_ui.c",       "set_str.c",    "tdiv_q_ui.c",
            "set_ui.c",       "fits_uint.c",  "cfdiv_r_2exp.c",
            "cfdiv_q_2exp.c", "divexact.c",   "iset_str.c",
            "iset_ui.c",
        },
    });
    gmp.addCSourceFiles(.{
        .root = gmp_dep.path("mpq"),
        .files = &.{
            "set_si.c",
            "get_str.c",
        },
    });
    gmp.addCSourceFiles(.{
        .root = gmp_dep.path("mpf"),
        .files = &.{
            "set_si.c",
            "get_str.c",
        },
    });

    gmp.addCSourceFile(.{ .file = header_files.addCopyFile(
        try genTable(
            b,
            gmp_dep,
            "gen-bases",
            "table",
            0,
            limb_bits,
        ),
        "mp_bases.c",
    ) });

    gmp.addCSourceFiles(.{
        .root = gmp_dep.path("cxx"),
        .files = &.{
            "isfuns.cc",
            "ismpf.cc",
            "ismpq.cc",
            "ismpz.cc",
            "ismpznw.cc",
            "limits.cc",
            "osdoprnti.cc",
            "osfuns.cc",
            "osmpf.cc",
            "osmpq.cc",
            "osmpz.cc",
        },
    });

    gmp.addCSourceFiles(.{
        .root = gmp_dep.path("mpn/generic"),
        .files = &.{
            "add.c",                   "fib2m.c",                        "mullo_basecase.c",
            "sqrtrem.c",               "add_1.c",                        "gcd.c",
            "mullo_n.c",               "strongfibo.c",                   "add_err1_n.c",
            "gcd_1.c",                 "mulmid.c",                       "sub.c",
            "add_err2_n.c",            "gcd_11.c",                       "mulmid_basecase.c",
            "sub_1.c",                 "add_err3_n.c",                   "gcd_22.c",
            "mulmid_n.c",              "sub_err1_n.c",                   "gcd_subdiv_step.c",
            "mulmod_bknp1.c",          "sub_err2_n.c",                   "add_n_sub_n.c",
            "gcdext.c",                "mulmod_bnm1.c",                  "sub_err3_n.c",
            "addmul_1.c",              "gcdext_1.c",                     "neg.c",
            "bdiv_dbm1c.c",            "gcdext_lehmer.c",                "nussbaumer_mul.c",
            "submul_1.c",              "bdiv_q.c",                       "get_d.c",
            "perfpow.c",               "tdiv_qr.c",                      "bdiv_q_1.c",
            "get_str.c",               "perfsqr.c",                      "toom22_mul.c",
            "bdiv_qr.c",               "toom2_sqr.c",                    "binvert.c",
            "hgcd.c",                  "pow_1.c",                        "toom32_mul.c",
            "broot.c",                 "powlo.c",                        "toom33_mul.c",
            "brootinv.c",              "hgcd2.c",                        "powm.c",
            "toom3_sqr.c",             "bsqrt.c",                        "hgcd2_jacobi.c",
            "pre_divrem_1.c",          "toom42_mul.c",                   "bsqrtinv.c",
            "hgcd_appr.c",             "pre_mod_1.c",                    "toom42_mulmid.c",
            "cmp.c",                   "hgcd_jacobi.c",                  "random.c",
            "toom43_mul.c",            "cnd_add_n.c",                    "hgcd_matrix.c",
            "random2.c",               "toom44_mul.c",                   "cnd_sub_n.c",
            "hgcd_reduce.c",           "redc_1.c",                       "toom4_sqr.c",
            "cnd_swap.c",              "hgcd_step.c",                    "redc_2.c",
            "toom52_mul.c",            "com.c",                          "invert.c",
            "redc_n.c",                "toom53_mul.c",                   "comb_tables.c",
            "invertappr.c",            "remove.c",                       "toom54_mul.c",
            "compute_powtab.c",        "jacbase.c",                      "rootrem.c",
            "toom62_mul.c",            "copyd.c",                        "jacobi.c",
            "rshift.c",                "toom63_mul.c",                   "copyi.c",
            "jacobi_2.c",              "sbpi1_bdiv_q.c",                 "toom6_sqr.c",
            "dcpi1_bdiv_q.c",          "sbpi1_bdiv_qr.c",                "toom6h_mul.c",
            "dcpi1_bdiv_qr.c",         "lshift.c",                       "sbpi1_bdiv_r.c",
            "toom8_sqr.c",             "dcpi1_div_q.c",                  "lshiftc.c",
            "sbpi1_div_q.c",           "toom8h_mul.c",                   "dcpi1_div_qr.c",
            "matrix22_mul.c",          "sbpi1_div_qr.c",                 "toom_couple_handling.c",
            "dcpi1_divappr_q.c",       "matrix22_mul1_inverse_vector.c", "sbpi1_divappr_q.c",
            "toom_eval_dgr3_pm1.c",    "div_q.c",                        "mod_1.c",
            "scan0.c",                 "toom_eval_dgr3_pm2.c",           "div_qr_1.c",
            "mod_1_1.c",               "scan1.c",                        "toom_eval_pm1.c",
            "div_qr_1n_pi1.c",         "mod_1_2.c",                      "toom_eval_pm2.c",
            "div_qr_1n_pi2.c",         "mod_1_3.c",                      "toom_eval_pm2exp.c",
            "div_qr_1u_pi2.c",         "mod_1_4.c",                      "sec_invert.c",
            "toom_eval_pm2rexp.c",     "div_qr_2.c",                     "mod_34lsub1.c",
            "sec_mul.c",               "toom_interpolate_12pts.c",       "div_qr_2n_pi1.c",
            "mode1o.c",                "toom_interpolate_16pts.c",       "div_qr_2u_pi1.c",
            "mu_bdiv_q.c",             "sec_powm.c",                     "toom_interpolate_5pts.c",
            "dive_1.c",                "mu_bdiv_qr.c",                   "sec_sqr.c",
            "toom_interpolate_6pts.c", "diveby3.c",                      "mu_div_q.c",
            "sec_tabselect.c",         "toom_interpolate_7pts.c",        "divexact.c",
            "mu_div_qr.c",             "set_str.c",                      "toom_interpolate_8pts.c",
            "divis.c",                 "mu_divappr_q.c",                 "sizeinbase.c",
            "trialdiv.c",              "divrem.c",                       "mul.c",
            "sqr.c",                   "divrem_1.c",                     "sqr_basecase.c",
            "zero.c",                  "divrem_2.c",                     "mul_basecase.c",
            "sqrlo.c",                 "zero_p.c",                       "dump.c",
            "mul_fft.c",               "sqrlo_basecase.c",               "fib2_ui.c",
            "mul_n.c",                 "sqrmod_bnm1.c",
        },
        .flags = &.{"-DLONGLONG_STANDALONE"},
    });

    inline for (.{
        "-DOPERATION_sec_div_qr",
        "-DOPERATION_sec_div_r",
    }) |op| {
        gmp.addCSourceFile(.{
            .file = gmp_dep.path("mpn/generic/sec_div.c"),
            .flags = &.{op},
        });
    }

    inline for (.{
        "-DOPERATION_popcount",
        "-DOPERATION_hamdist",
    }) |op| {
        gmp.addCSourceFile(.{
            .file = gmp_dep.path("mpn/generic/popham.c"),
            .flags = &.{op},
        });
    }

    inline for (.{
        "-DOPERATION_sec_pi1_div_qr",
        "-DOPERATION_sec_pi1_div_r",
    }) |op| {
        gmp.addCSourceFile(.{
            .file = gmp_dep.path("mpn/generic/sec_pi1_div.c"),
            .flags = &.{op},
        });
    }

    inline for (.{
        "-DOPERATION_and_n",
        "-DOPERATION_andn_n",
        "-DOPERATION_nand_n",
        "-DOPERATION_ior_n",
        "-DOPERATION_iorn_n",
        "-DOPERATION_nior_n",
        "-DOPERATION_xor_n",
        "-DOPERATION_xnor_n",
    }) |op| {
        gmp.addCSourceFile(.{
            .file = gmp_dep.path("mpn/generic/logops_n.c"),
            .flags = &.{op},
        });
    }

    inline for (.{
        "-DOPERATION_sec_add_1",
        "-DOPERATION_sec_sub_1",
    }) |op| {
        gmp.addCSourceFile(.{
            .file = gmp_dep.path("mpn/generic/sec_aors_1.c"),
            .flags = &.{op},
        });
    }

    const os_path, const arch_asm: struct {
        []const u8,
        []const []const u8,
    } = switch (target.result.os.tag) {
        .macos => .{ "macos", switch (target.result.cpu.arch) {
            .aarch64 => .{ "arm64", &.{
                "add_n_add.s",        "add_n_sub.s",
                "addlsh1_n_add.s",    "addlsh1_n_sub.s",
                "addlsh1_n_rsb.s",    "addlsh2_n_add.s",
                "addlsh2_n_sub.s",    "addlsh2_n_rsb.s",
                "rsh1sub_n_add.s",    "rsh1sub_n_sub.s",
                "sqr_diag_addlsh1.s", "invert_limb.s",
                "mul_1.s",
            } },
            else => @panic("TODO"),
        } },
        .linux => .{ "linux", switch (target.result.cpu.arch) {
            .x86_64 => .{ "x86_64", &.{
                "add_n_add.s",        "add_n_sub.s",
                "addlsh1_n_add.s",    "addlsh1_n_rsb.s",
                "addlsh2_n_add.s",    "addlsh2_n_rsb.s",
                "invert_limb.s",      "invert_limb_table.s",
                "addlsh_n_add.s",     "addlsh_n_rsb.s",
                "rsh1add_n_add.s",    "rsh1add_n_sub.s",
                "mul_1.s",            "mul_2.s",
                "mode1o.s",           "sublsh1_n.s",
                "sqr_diag_addlsh1.s",
            } },
            else => @panic("TODO"),
        } },
        else => @panic("TODO"),
    };

    const arch_path, const asm_sources = arch_asm;
    for (asm_sources) |source| {
        gmp.addAssemblyFile(b.path(b.fmt("vendor/{s}/{s}/{s}", .{
            os_path,
            arch_path,
            source,
        })));
    }
}

fn genTable(
    b: *std.Build,
    gmp_dep: *std.Build.Dependency,
    name: []const u8,
    maybe_arg: ?[]const u8,
    maybe_nail_bits: ?u64,
    maybe_limb_bits: ?u64,
) !std.Build.LazyPath {
    const gen_fib = b.addExecutable(.{
        .name = name,
        .root_module = b.createModule(.{
            .target = b.graph.host,
            .optimize = .ReleaseSafe,
        }),
    });
    gen_fib.linkLibC();
    gen_fib.addCSourceFile(.{ .file = gmp_dep.path(b.fmt("{s}.c", .{name})) });
    const run_gen_fib = b.addRunArtifact(gen_fib);
    if (maybe_arg) |arg| run_gen_fib.addArg(arg);
    if (maybe_limb_bits) |limb_bits| run_gen_fib.addArg(b.fmt("{d}", .{limb_bits}));
    if (maybe_nail_bits) |nail_bits| run_gen_fib.addArg(b.fmt("{d}", .{nail_bits}));
    return run_gen_fib.captureStdOut();
}

const native_map = std.EnumMap(std.Target.Cpu.Arch, struct {
    HAVE_NATIVE_mpn_add_n: ?u32 = null,
    HAVE_NATIVE_mpn_add_n_sub_n: ?u32 = null,
    HAVE_NATIVE_mpn_add_nc: ?u32 = null,
    HAVE_NATIVE_mpn_addaddmul_1msb0: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh1_n: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh2_n: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh_n: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh1_nc: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh2_nc: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh_nc: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh1_n_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh2_n_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh_n_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh1_nc_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh2_nc_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh_nc_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh1_n_ip2: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh2_n_ip2: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh_n_ip2: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh1_nc_ip2: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh2_nc_ip2: ?u32 = null,
    HAVE_NATIVE_mpn_addlsh_nc_ip2: ?u32 = null,
    HAVE_NATIVE_mpn_addmul_1c: ?u32 = null,
    HAVE_NATIVE_mpn_addmul_2: ?u32 = null,
    HAVE_NATIVE_mpn_addmul_3: ?u32 = null,
    HAVE_NATIVE_mpn_addmul_4: ?u32 = null,
    HAVE_NATIVE_mpn_addmul_5: ?u32 = null,
    HAVE_NATIVE_mpn_addmul_6: ?u32 = null,
    HAVE_NATIVE_mpn_addmul_7: ?u32 = null,
    HAVE_NATIVE_mpn_addmul_8: ?u32 = null,
    HAVE_NATIVE_mpn_addmul_2s: ?u32 = null,
    HAVE_NATIVE_mpn_and_n: ?u32 = null,
    HAVE_NATIVE_mpn_andn_n: ?u32 = null,
    HAVE_NATIVE_mpn_bdiv_dbm1c: ?u32 = null,
    HAVE_NATIVE_mpn_bdiv_q_1: ?u32 = null,
    HAVE_NATIVE_mpn_pi1_bdiv_q_1: ?u32 = null,
    HAVE_NATIVE_mpn_cnd_add_n: ?u32 = null,
    HAVE_NATIVE_mpn_cnd_sub_n: ?u32 = null,
    HAVE_NATIVE_mpn_com: ?u32 = null,
    HAVE_NATIVE_mpn_copyd: ?u32 = null,
    HAVE_NATIVE_mpn_copyi: ?u32 = null,
    HAVE_NATIVE_mpn_div_qr_1n_pi1: ?u32 = null,
    HAVE_NATIVE_mpn_div_qr_2: ?u32 = null,
    HAVE_NATIVE_mpn_divexact_1: ?u32 = null,
    HAVE_NATIVE_mpn_divexact_by3c: ?u32 = null,
    HAVE_NATIVE_mpn_divrem_1: ?u32 = null,
    HAVE_NATIVE_mpn_divrem_1c: ?u32 = null,
    HAVE_NATIVE_mpn_divrem_2: ?u32 = null,
    HAVE_NATIVE_mpn_gcd_1: ?u32 = null,
    HAVE_NATIVE_mpn_gcd_11: ?u32 = null,
    HAVE_NATIVE_mpn_gcd_22: ?u32 = null,
    HAVE_NATIVE_mpn_hamdist: ?u32 = null,
    HAVE_NATIVE_mpn_invert_limb: ?u32 = null,
    HAVE_NATIVE_mpn_ior_n: ?u32 = null,
    HAVE_NATIVE_mpn_iorn_n: ?u32 = null,
    HAVE_NATIVE_mpn_lshift: ?u32 = null,
    HAVE_NATIVE_mpn_lshiftc: ?u32 = null,
    HAVE_NATIVE_mpn_lshsub_n: ?u32 = null,
    HAVE_NATIVE_mpn_mod_1: ?u32 = null,
    HAVE_NATIVE_mpn_mod_1_1p: ?u32 = null,
    HAVE_NATIVE_mpn_mod_1c: ?u32 = null,
    HAVE_NATIVE_mpn_mod_1s_2p: ?u32 = null,
    HAVE_NATIVE_mpn_mod_1s_4p: ?u32 = null,
    HAVE_NATIVE_mpn_mod_34lsub1: ?u32 = null,
    HAVE_NATIVE_mpn_modexact_1_odd: ?u32 = null,
    HAVE_NATIVE_mpn_modexact_1c_odd: ?u32 = null,
    HAVE_NATIVE_mpn_mul_1: ?u32 = null,
    HAVE_NATIVE_mpn_mul_1c: ?u32 = null,
    HAVE_NATIVE_mpn_mul_2: ?u32 = null,
    HAVE_NATIVE_mpn_mul_3: ?u32 = null,
    HAVE_NATIVE_mpn_mul_4: ?u32 = null,
    HAVE_NATIVE_mpn_mul_5: ?u32 = null,
    HAVE_NATIVE_mpn_mul_6: ?u32 = null,
    HAVE_NATIVE_mpn_mul_basecase: ?u32 = null,
    HAVE_NATIVE_mpn_mullo_basecase: ?u32 = null,
    HAVE_NATIVE_mpn_nand_n: ?u32 = null,
    HAVE_NATIVE_mpn_nior_n: ?u32 = null,
    HAVE_NATIVE_mpn_popcount: ?u32 = null,
    HAVE_NATIVE_mpn_preinv_divrem_1: ?u32 = null,
    HAVE_NATIVE_mpn_preinv_mod_1: ?u32 = null,
    HAVE_NATIVE_mpn_redc_1: ?u32 = null,
    HAVE_NATIVE_mpn_redc_2: ?u32 = null,
    HAVE_NATIVE_mpn_rsblsh1_n: ?u32 = null,
    HAVE_NATIVE_mpn_rsblsh2_n: ?u32 = null,
    HAVE_NATIVE_mpn_rsblsh_n: ?u32 = null,
    HAVE_NATIVE_mpn_rsblsh1_nc: ?u32 = null,
    HAVE_NATIVE_mpn_rsblsh2_nc: ?u32 = null,
    HAVE_NATIVE_mpn_rsblsh_nc: ?u32 = null,
    HAVE_NATIVE_mpn_rsh1add_n: ?u32 = null,
    HAVE_NATIVE_mpn_rsh1add_nc: ?u32 = null,
    HAVE_NATIVE_mpn_rsh1sub_n: ?u32 = null,
    HAVE_NATIVE_mpn_rsh1sub_nc: ?u32 = null,
    HAVE_NATIVE_mpn_rshift: ?u32 = null,
    HAVE_NATIVE_mpn_sbpi1_bdiv_r: ?u32 = null,
    HAVE_NATIVE_mpn_sqr_basecase: ?u32 = null,
    HAVE_NATIVE_mpn_sqr_diagonal: ?u32 = null,
    HAVE_NATIVE_mpn_sqr_diag_addlsh1: ?u32 = null,
    HAVE_NATIVE_mpn_sub_n: ?u32 = null,
    HAVE_NATIVE_mpn_sub_nc: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh1_n: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh2_n: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh_n: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh1_nc: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh2_nc: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh_nc: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh1_n_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh2_n_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh_n_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh1_nc_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh2_nc_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_sublsh_nc_ip1: ?u32 = null,
    HAVE_NATIVE_mpn_submul_1c: ?u32 = null,
    HAVE_NATIVE_mpn_tabselect: ?u32 = null,
    HAVE_NATIVE_mpn_udiv_qrnnd: ?u32 = null,
    HAVE_NATIVE_mpn_udiv_qrnnd_r: ?u32 = null,
    HAVE_NATIVE_mpn_umul_ppmm: ?u32 = null,
    HAVE_NATIVE_mpn_umul_ppmm_r: ?u32 = null,
    HAVE_NATIVE_mpn_xor_n: ?u32 = null,
    HAVE_NATIVE_mpn_xnor_n: ?u32 = null,
}).init(.{
    .x86_64 = .{
        .HAVE_NATIVE_mpn_add_n = 1,
        .HAVE_NATIVE_mpn_add_nc = 1,
        .HAVE_NATIVE_mpn_addlsh1_n = 1,
        .HAVE_NATIVE_mpn_addlsh2_n = 1,
        .HAVE_NATIVE_mpn_addlsh_n = 1,
        .HAVE_NATIVE_mpn_addlsh1_nc = 1,
        .HAVE_NATIVE_mpn_and_n = 1,
        .HAVE_NATIVE_mpn_andn_n = 1,
        .HAVE_NATIVE_mpn_bdiv_dbm1c = 1,
        .HAVE_NATIVE_mpn_bdiv_q_1 = 1,
        .HAVE_NATIVE_mpn_pi1_bdiv_q_1 = 1,
        .HAVE_NATIVE_mpn_cnd_add_n = 1,
        .HAVE_NATIVE_mpn_cnd_sub_n = 1,
        .HAVE_NATIVE_mpn_com = 1,
        .HAVE_NATIVE_mpn_copyd = 1,
        .HAVE_NATIVE_mpn_copyi = 1,
        .HAVE_NATIVE_mpn_div_qr_1n_pi1 = 1,
        .HAVE_NATIVE_mpn_divexact_1 = 1,
        .HAVE_NATIVE_mpn_divrem_1 = 1,
        .HAVE_NATIVE_mpn_divrem_2 = 1,
        .HAVE_NATIVE_mpn_gcd_11 = 1,
        .HAVE_NATIVE_mpn_gcd_22 = 1,
        .HAVE_NATIVE_mpn_hamdist = 1,
        .HAVE_NATIVE_mpn_invert_limb = 1,
        .HAVE_NATIVE_mpn_ior_n = 1,
        .HAVE_NATIVE_mpn_iorn_n = 1,
        .HAVE_NATIVE_mpn_lshift = 1,
        .HAVE_NATIVE_mpn_lshiftc = 1,
        .HAVE_NATIVE_mpn_mod_1_1p = 1,
        .HAVE_NATIVE_mpn_mod_1s_2p = 1,
        .HAVE_NATIVE_mpn_mod_1s_4p = 1,
        .HAVE_NATIVE_mpn_mod_34lsub1 = 1,
        .HAVE_NATIVE_mpn_modexact_1_odd = 1,
        .HAVE_NATIVE_mpn_modexact_1c_odd = 1,
        .HAVE_NATIVE_mpn_mul_1 = 1,
        .HAVE_NATIVE_mpn_mul_1c = 1,
        .HAVE_NATIVE_mpn_mul_2 = 1,
        .HAVE_NATIVE_mpn_mul_basecase = 1,
        .HAVE_NATIVE_mpn_mullo_basecase = 1,
        .HAVE_NATIVE_mpn_nand_n = 1,
        .HAVE_NATIVE_mpn_nior_n = 1,
        .HAVE_NATIVE_mpn_popcount = 1,
        .HAVE_NATIVE_mpn_preinv_divrem_1 = 1,
        .HAVE_NATIVE_mpn_rsblsh1_n = 1,
        .HAVE_NATIVE_mpn_rsblsh2_n = 1,
        .HAVE_NATIVE_mpn_rsblsh_n = 1,
        .HAVE_NATIVE_mpn_rsblsh1_nc = 1,
        .HAVE_NATIVE_mpn_rsh1add_n = 1,
        .HAVE_NATIVE_mpn_rsh1add_nc = 1,
        .HAVE_NATIVE_mpn_rsh1sub_n = 1,
        .HAVE_NATIVE_mpn_rsh1sub_nc = 1,
        .HAVE_NATIVE_mpn_rshift = 1,
        .HAVE_NATIVE_mpn_sbpi1_bdiv_r = 1,
        .HAVE_NATIVE_mpn_sqr_basecase = 1,
        .HAVE_NATIVE_mpn_sqr_diag_addlsh1 = 1,
        .HAVE_NATIVE_mpn_sub_n = 1,
        .HAVE_NATIVE_mpn_sub_nc = 1,
        .HAVE_NATIVE_mpn_sublsh1_n = 1,
        .HAVE_NATIVE_mpn_sublsh1_nc = 1,
        .HAVE_NATIVE_mpn_xor_n = 1,
        .HAVE_NATIVE_mpn_xnor_n = 1,
    },
    .aarch64 = .{
        .HAVE_NATIVE_mpn_add_n = 1,
        .HAVE_NATIVE_mpn_add_nc = 1,
        .HAVE_NATIVE_mpn_addlsh1_n = 1,
        .HAVE_NATIVE_mpn_addlsh2_n = 1,
        .HAVE_NATIVE_mpn_andn_n = 1,
        .HAVE_NATIVE_mpn_bdiv_dbm1c = 1,
        .HAVE_NATIVE_mpn_bdiv_q_1 = 1,
        .HAVE_NATIVE_mpn_pi1_bdiv_q_1 = 1,
        .HAVE_NATIVE_mpn_cnd_add_n = 1,
        .HAVE_NATIVE_mpn_cnd_sub_n = 1,
        .HAVE_NATIVE_mpn_com = 1,
        .HAVE_NATIVE_mpn_copyd = 1,
        .HAVE_NATIVE_mpn_copyi = 1,
        .HAVE_NATIVE_mpn_divrem_1 = 1,
        .HAVE_NATIVE_mpn_gcd_11 = 1,
        .HAVE_NATIVE_mpn_gcd_22 = 1,
        .HAVE_NATIVE_mpn_hamdist = 1,
        .HAVE_NATIVE_mpn_invert_limb = 1,
        .HAVE_NATIVE_mpn_ior_n = 1,
        .HAVE_NATIVE_mpn_iorn_n = 1,
        .HAVE_NATIVE_mpn_lshift = 1,
        .HAVE_NATIVE_mpn_lshiftc = 1,
        .HAVE_NATIVE_mpn_mod_34lsub1 = 1,
        .HAVE_NATIVE_mpn_mul_1 = 1,
        .HAVE_NATIVE_mpn_mul_1c = 1,
        .HAVE_NATIVE_mpn_nand_n = 1,
        .HAVE_NATIVE_mpn_nior_n = 1,
        .HAVE_NATIVE_mpn_popcount = 1,
        .HAVE_NATIVE_mpn_preinv_divrem_1 = 1,
        .HAVE_NATIVE_mpn_rsblsh1_n = 1,
        .HAVE_NATIVE_mpn_rsblsh2_n = 1,
        .HAVE_NATIVE_mpn_rsh1add_n = 1,
        .HAVE_NATIVE_mpn_rsh1sub_n = 1,
        .HAVE_NATIVE_mpn_rshift = 1,
        .HAVE_NATIVE_mpn_sqr_diag_addlsh1 = 1,
        .HAVE_NATIVE_mpn_sub_n = 1,
        .HAVE_NATIVE_mpn_sub_nc = 1,
        .HAVE_NATIVE_mpn_sublsh1_n = 1,
        .HAVE_NATIVE_mpn_sublsh2_n = 1,
        .HAVE_NATIVE_mpn_xor_n = 1,
        .HAVE_NATIVE_mpn_xnor_n = 1,
    },
});

fn makeConfigHeader(
    b: *std.Build,
    gmp_dep: *std.Build.Dependency,
    target: std.Build.ResolvedTarget,
) *std.Build.Step.ConfigHeader {
    const t = target.result;

    const config = b.addConfigHeader(.{
        .style = .{ .autoconf_undef = gmp_dep.path("config.in") },
        .include_path = "config.h",
    }, .{
        .HAVE_ALARM = 1,
        .HAVE_ALLOCA = 1,
        .HAVE_ALLOCA_H = 1,
        .HAVE_ATTRIBUTE_CONST = 1,
        .HAVE_ATTRIBUTE_MALLOC = 1,
        .HAVE_ATTRIBUTE_MODE = 1,
        .HAVE_ATTRIBUTE_NORETURN = 1,
        .HAVE_ATTR_GET = 1,
        .HAVE_CALLING_CONVENTIONS = 1,
        .HAVE_CLOCK = 1,
        .HAVE_CLOCK_GETTIME = 1,
        .HAVE_CPUTIME = 1,
        .HAVE_DECL_FGETC = 1,
        .HAVE_DECL_FSCANF = 1,
        .HAVE_DECL_OPTARG = 1,
        .HAVE_DECL_SYS_ERRLIST = 1,
        .HAVE_DECL_SYS_NERR = 1,
        .HAVE_DECL_UNGETC = 1,
        .HAVE_DECL_VFPRINTF = 1,
        .HAVE_DLFCN_H = 1,

        .WANT_TMP_ALLOCA = 1,
        .WANT_TMP_REENTRANT = null,
        .WANT_TMP_NOTREENTRANT = null,
        .WANT_TMP_DEBUG = null,

        .HAVE_DOUBLE_IEEE_LITTLE_ENDIAN = 1,
        .HAVE_DOUBLE_IEEE_LITTLE_SWAPPED = null,
        .HAVE_DOUBLE_IEEE_BIG_ENDIAN = null,
        .HAVE_DOUBLE_VAX_D = null,
        .HAVE_DOUBLE_VAX_G = null,
        .HAVE_DOUBLE_CRAY_CFP = null,

        .HAVE_FCNTL_H = 1,
        .HAVE_FLOAT_H = 1,
        .HAVE_GETPAGESIZE = 1,
        .HAVE_GETRUSAGE = 1,
        .HAVE_GETSYSINFO = 1,
        .HAVE_GETTIMEOFDAY = 1,
        .HAVE_HIDDEN_ALIAS = 1,

        .HAVE_HOST_CPU_FAMILY_m68k = has(t.cpu.arch == .m68k),
        .HAVE_HOST_CPU_FAMILY_powerpc = has(t.cpu.arch == .powerpc),
        .HAVE_HOST_CPU_FAMILY_x86 = has(t.cpu.arch == .x86),
        .HAVE_HOST_CPU_FAMILY_x86_64 = has(t.cpu.arch == .x86_64),
        .HAVE_HOST_CPU_ivybridge = has(std.mem.eql(u8, t.cpu.model.name, "ivybridge")),
        .HAVE_HOST_CPU_haswell = has(std.mem.eql(u8, t.cpu.model.name, "haswell")),
        .HAVE_HOST_CPU_broadwell = has(std.mem.eql(u8, t.cpu.model.name, "broadwell")),
        .HAVE_HOST_CPU_nehalem = has(std.mem.eql(u8, t.cpu.model.name, "nehalem")),
        .HAVE_HOST_CPU_westmere = has(std.mem.eql(u8, t.cpu.model.name, "nehalem")),

        .NO_ASM = 1,

        .WANT_PROFILING_GPROF = null,
        .WANT_PROFILING_INSTRUMENT = null,
        .WANT_PROFILING_PROF = null,

        .HAVE_INTPTR_T = 1,
        .HAVE_INTTYPES_H = 1,
        .HAVE_INVENT_H = 1,
        .HAVE_LANGINFO_H = 1,
        .HAVE_LIMB_BIG_ENDIAN = 1,
        .HAVE_LIMB_LITTLE_ENDIAN = 1,
        .HAVE_LOCALECONV = 1,
        .HAVE_LOCALE_H = 1,
        .HAVE_LONG_DOUBLE = 1,
        .HAVE_LONG_LONG = 1,
        .HAVE_MACHINE_HAL_SYSINFO_H = 1,
        .HAVE_MEMORY_H = 1,
        .HAVE_MEMSET = 1,
        .HAVE_MMAP = 1,
        .HAVE_MPROTECT = 1,

        .AC_APPLE_UNIVERSAL_BUILD = null,
        .GMP_MPARAM_H_SUGGEST = null,
        .HAVE_HOST_CPU_FAMILY_alpha = null,
        .HAVE_HOST_CPU_FAMILY_power = null,
        .HAVE_HOST_CPU_alphaev67 = null,
        .HAVE_HOST_CPU_alphaev68 = null,
        .HAVE_HOST_CPU_alphaev7 = null,
        .HAVE_HOST_CPU_m68020 = null,
        .HAVE_HOST_CPU_m68030 = null,
        .HAVE_HOST_CPU_m68040 = null,
        .HAVE_HOST_CPU_m68060 = null,
        .HAVE_HOST_CPU_m68360 = null,
        .HAVE_HOST_CPU_powerpc604 = null,
        .HAVE_HOST_CPU_powerpc604e = null,
        .HAVE_HOST_CPU_powerpc750 = null,
        .HAVE_HOST_CPU_powerpc7400 = null,
        .HAVE_HOST_CPU_supersparc = null,
        .HAVE_HOST_CPU_i386 = null,
        .HAVE_HOST_CPU_i586 = null,
        .HAVE_HOST_CPU_i686 = null,
        .HAVE_HOST_CPU_pentium = null,
        .HAVE_HOST_CPU_pentiummmx = null,
        .HAVE_HOST_CPU_pentiumpro = null,
        .HAVE_HOST_CPU_pentium2 = null,
        .HAVE_HOST_CPU_pentium3 = null,
        .HAVE_HOST_CPU_pentium4 = null,
        .HAVE_HOST_CPU_core2 = null,
        .HAVE_HOST_CPU_sandybridge = null,
        .HAVE_HOST_CPU_skylake = null,
        .HAVE_HOST_CPU_silvermont = null,
        .HAVE_HOST_CPU_goldmont = null,
        .HAVE_HOST_CPU_tremont = null,
        .HAVE_HOST_CPU_k8 = null,
        .HAVE_HOST_CPU_k10 = null,
        .HAVE_HOST_CPU_bulldozer = null,
        .HAVE_HOST_CPU_piledriver = null,
        .HAVE_HOST_CPU_steamroller = null,
        .HAVE_HOST_CPU_excavator = null,
        .HAVE_HOST_CPU_zen = null,
        .HAVE_HOST_CPU_bobcat = null,
        .HAVE_HOST_CPU_jaguar = null,
        .HAVE_HOST_CPU_s390_z900 = null,
        .HAVE_HOST_CPU_s390_z990 = null,
        .HAVE_HOST_CPU_s390_z10 = null,
        .HAVE_HOST_CPU_s390_z196 = null,
        .HAVE_HOST_CPU_s390_z13 = null,
        .HAVE_HOST_CPU_s390_z14 = null,
        .HAVE_HOST_CPU_s390_z15 = null,
        .HAVE_HOST_CPU_s390_zarch = null,
        .HAVE_HOST_CPU_s390_z9 = null,

        .HAVE_INTMAX_T = 1,
        .HAVE_NL_LANGINFO = 1,
        .HAVE_NL_TYPES_H = 1,
        .HAVE_OBSTACK_VPRINTF = null,
        .HAVE_POPEN = 1,
        .HAVE_PROCESSOR_INFO = 1,
        .HAVE_PSP_ITICKSPERCLKTICK = null,
        .HAVE_PSTAT_GETPROCESSOR = null,
        .HAVE_PTRDIFF_T = 1,
        .HAVE_QUAD_T = 1,
        .HAVE_RAISE = 1,
        .HAVE_READ_REAL_TIME = null,
        .HAVE_SIGACTION = 1,
        .HAVE_SIGALTSTACK = 1,
        .HAVE_SIGSTACK = 1,
        .HAVE_SPEED_CYCLECOUNTER = null,
        .HAVE_SSTREAM = null,
        .HAVE_STACK_T = 1,
        .HAVE_STDINT_H = 1,
        .HAVE_STDLIB_H = 1,
        .HAVE_STD__LOCALE = null,
        .HAVE_STRCHR = 1,
        .HAVE_STRERROR = 1,
        .HAVE_STRINGS_H = 1,
        .HAVE_STRING_H = 1,
        .HAVE_STRNLEN = 1,
        .HAVE_STRTOL = 1,
        .HAVE_STRTOUL = 1,
        .HAVE_SYSCONF = 1,
        .HAVE_SYSCTL = 1,
        .HAVE_SYSCTLBYNAME = 1,
        .HAVE_SYSSGI = null,
        .HAVE_SYS_ATTRIBUTES_H = null,
        .HAVE_SYS_IOGRAPH_H = null,
        .HAVE_SYS_MMAN_H = 1,
        .HAVE_SYS_PARAM_H = 1,
        .HAVE_SYS_PROCESSOR_H = null,
        .HAVE_SYS_PSTAT_H = null,
        .HAVE_SYS_RESOURCE_H = 1,
        .HAVE_SYS_STAT_H = 1,
        .HAVE_SYS_SYSCTL_H = 1,
        .HAVE_SYS_SYSINFO_H = null,
        .HAVE_SYS_SYSSGI_H = null,
        .HAVE_SYS_SYSTEMCFG_H = null,
        .HAVE_SYS_TIMES_H = 1,
        .HAVE_SYS_TIME_H = 1,
        .HAVE_SYS_TYPES_H = 1,
        .HAVE_TIMES = 1,
        .HAVE_UINT_LEAST32_T = 1,
        .HAVE_UNISTD_H = 1,
        .HAVE_VSNPRINTF = 1,
        .HOST_DOS64 = null,
        .LSYM_PREFIX = 1,
        .LT_OBJDIR = 1,
        .PACKAGE = 1,
        .PACKAGE_BUGREPORT = "gmp-bugs@gmplib.org (see https://gmplib.org/manual/Reporting-Bugs.html)",
        .PACKAGE_NAME = "GNU MP",
        .PACKAGE_STRING = "GNU MP 6.3.0",
        .PACKAGE_TARNAME = "gmp",
        .PACKAGE_URL = "http://www.gnu.org/software/gmp/",
        .PACKAGE_VERSION = "6.3.0",
        .RETSIGTYPE = .void,
        .SIZEOF_MP_LIMB_T = 8,
        .SIZEOF_UNSIGNED = 4,
        .SIZEOF_UNSIGNED_LONG = 8,
        .SIZEOF_UNSIGNED_SHORT = 2,
        .SIZEOF_VOID_P = 8,
        .SSCANF_WRITABLE_INPUT = null,
        .STDC_HEADERS = 1,
        .TIME_WITH_SYS_TIME = 1,
        .TUNE_SQR_TOOM2_MAX = "SQR_TOOM2_MAX_GENERIC",
        .VERSION = 1,
        .WANT_FFT = 1,
        .YYTEXT_POINTER = 1,
        .restrict = .__restrict,

        .WANT_OLD_FFT_FULL = null,
        .WANT_ASSERT = null,
        .WANT_FAKE_CPUID = null,
        .WORDS_BIGENDIAN = null,
        .X86_ASM_MULX = null,
        .WANT_FAT_BINARY = null,
        .@"inline" = null,
        .@"volatile" = null,
    });

    const entry = native_map.get(t.cpu.arch) orelse @panic("support arch");
    config.addValues(entry);

    return config;
}

fn has(pred: bool) ?u1 {
    return if (pred) 1 else null;
}
