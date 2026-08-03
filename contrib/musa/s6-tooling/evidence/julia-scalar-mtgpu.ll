; ModuleID = 'start'
source_filename = "start"
target datalayout = "e-p:64:64:64:64-p1:64:64:64:64-p2:64:64:64:64-p3:32:32-p4:32:32-p5:64:64-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128"
target triple = "mtgpu-mt-musa"

define cc102 void @julia_scalar_kernel(i64 zeroext %0, i32 zeroext %1, i32 zeroext %2) local_unnamed_addr #0 !dbg !5 {
top:
  %3 = mul i32 %1, 3, !dbg !8
  %4 = add i32 %3, %2, !dbg !12
  %5 = inttoptr i64 %0 to i32*, !dbg !14
  store i32 %4, i32* %5, align 1, !dbg !14, !tbaa !18, !alias.scope !22, !noalias !25
  ret void, !dbg !30
}

attributes #0 = { "frame-pointer"="all" "target-cpu"="mp_31" }

!llvm.module.flags = !{!0, !1}
!llvm.dbg.cu = !{!2}
!julia.kernel = !{!4}

!0 = !{i32 2, !"Dwarf Version", i32 4}
!1 = !{i32 2, !"Debug Info Version", i32 3}
!2 = distinct !DICompileUnit(language: DW_LANG_Julia, file: !3, producer: "julia", isOptimized: true, runtimeVersion: 0, emissionKind: LineTablesOnly, nameTableKind: None)
!3 = !DIFile(filename: "/workspace/contrib/musa/s6-tooling/sealed_direct_route.jl", directory: ".")
!4 = !{void (i64, i32, i32)* @julia_scalar_kernel}
!5 = distinct !DISubprogram(name: "scalar_kernel", linkageName: "julia_scalar_kernel_216", scope: null, file: !3, line: 53, type: !6, scopeLine: 53, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !7)
!6 = !DISubroutineType(types: !7)
!7 = !{}
!8 = !DILocation(line: 88, scope: !9, inlinedAt: !11)
!9 = distinct !DISubprogram(name: "*;", linkageName: "*", scope: !10, file: !10, type: !6, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !7)
!10 = !DIFile(filename: "int.jl", directory: ".")
!11 = !DILocation(line: 54, scope: !5)
!12 = !DILocation(line: 87, scope: !13, inlinedAt: !11)
!13 = distinct !DISubprogram(name: "+;", linkageName: "+", scope: !10, file: !10, type: !6, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !7)
!14 = !DILocation(line: 126, scope: !15, inlinedAt: !17)
!15 = distinct !DISubprogram(name: "unsafe_store!;", linkageName: "unsafe_store!", scope: !16, file: !16, type: !6, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !7)
!16 = !DIFile(filename: "pointer.jl", directory: ".")
!17 = !DILocation(line: 126, scope: !15, inlinedAt: !11)
!18 = !{!19, !19, i64 0}
!19 = !{!"jtbaa_data", !20, i64 0}
!20 = !{!"jtbaa", !21, i64 0}
!21 = !{!"jtbaa"}
!22 = !{!23}
!23 = !{!"jnoalias_data", !24}
!24 = !{!"jnoalias"}
!25 = !{!26, !27, !28, !29}
!26 = !{!"jnoalias_gcframe", !24}
!27 = !{!"jnoalias_stack", !24}
!28 = !{!"jnoalias_typemd", !24}
!29 = !{!"jnoalias_const", !24}
!30 = !DILocation(line: 55, scope: !5)
