#gen::add_generator "C" gen_c::generate

namespace eval gen_c {

variable exit_jump 0

variable keywords {
auto
break
case
char
const
continue
default
do
double
else
enum
extern
float
for
goto
if
int
long
register
return
short
signed
sizeof
static
struct
switch
typedef
union
unsigned
void
volatile
while 
}

# Autogenerated with DRAKON Editor 1.29

proc assign { variable value } {
    #item 578
    return "$variable = $value;"
}

proc bad_case { switch_var select_icon_number } {
    #item 670
    if {[ string compare -nocase $switch_var "select" ] == 0} {
        #item 674
        set value "0"
    } else {
        #item 673
        set value $switch_var
    }
    #item 588
    return "UnexpectedBranch\($value\);"
}

proc block_close { } {
    #item 650
    return "\}"
}

proc commentator { text } {
    #item 143
    return "/* $text */"
}

proc compare { variable constant } {
    #item 584
    return "$variable == $constant"
}

proc contains_exit { links item_id } {
    foreach link $links {
        #item 532
        set linked_item [ lindex $link 0 ]
        #item 550
        if {$linked_item == $item_id} {
            #item 548
            return 1
        } else {
            
        }
    }
    #item 546
    return 0
}

proc declare { type name value } {
    #item 616
    return "$type $name = $value;"
}

proc else_start { } {
    #item 644
    return "\} else \{"
}

proc extract_return_type { text } {
    #item 491
    set skip [ string length "returns " ]
    set raw [ string range $text $skip end ]
    return [ string trim $raw ]
}

proc generate_body { gdb diagram_id start_item node_list items incoming } {
    #item 630
    set callbacks [ gen_cpp::make_callbacks "C" ]
    #item 622
    generate_body_goto \
    $gdb $diagram_id $start_item $node_list $items $incoming \
    $callbacks
}

proc generate_body_goto { gdb diagram_id start_item node_list items incoming callbacks } {
    #item 682
    variable exit_jump
    set exit_jump 0
    #item 623
    set tagger [ gen::get_callback \
    	$callbacks tag ]
    set comment [ gen::get_callback \
    	$callbacks comment ]
    set exit_door [ gen::get_optional_callback \
    	$callbacks exit_door ]
    #item 275
    set result {}
    set count [ llength $items ]
    #item 552
    print_switches result $node_list
    #item 290
    array set nodes $node_list
    array set incoming_map $incoming
    set i 0
    set base 0
    #item 515
    if {$count == 0} {
        
    } else {
        #item 517
        set first_item [ lindex $items 0 ]
        set first_incoming $incoming_map($first_item)
        #item 518
        if {$first_incoming == 0} {
            #item 516
            set skip_label 1
        } else {
            #item 519
            set skip_label 0
        }
        while { 1 } {
            #item 291
            set item_id [ lindex $items $i ]
            set node $nodes($item_id)	
            unpack $node body links
            unpack $body type text b
            #item 308
            set next_i [ expr { $i + 1 } ]
            #item 307
            if {$next_i < $count} {
                #item 309
                set next_item_id [ lindex $items $next_i ]
                #item 522
                set next_item_id [ lindex $items $next_i ]
                set next_incoming $incoming_map($next_item_id)
                #item 523
                if {($next_incoming == 1) && ([ contains_exit $links $next_item_id ])} {
                    #item 525
                    set next_skip_label 1
                } else {
                    #item 526
                    set next_skip_label 0
                }
            } else {
                #item 311
                set next_item_id ""
                #item 526
                set next_skip_label 0
            }
            #item 314
            if {$skip_label} {
                #item 343
                set tag [ $comment "item $item_id" ]
            } else {
                #item 485
                set tag [ label_name $item_id ]
                set tag [ $tagger $tag ]
            }
            #item 342
            gen::add_line result $tag 0 0
            #item 2950001
            if {$type == "if"} {
                #item 300
                p.generate_if \
                result $links $text $b $base \
                $next_item_id $items $i \
                $callbacks
            } else {
                #item 329
                p.generate_action \
                result $links $text $base \
                $next_item_id $items $i \
                $callbacks
            }
            #item 512
            set skip_label $next_skip_label
            #item 331
            lappend result ""
            #item 321
            incr i
            #item 322
            if {$i < $count} {
                
            } else {
                break
            }
        }
    }
    #item 693
    if {$exit_jump} {
        #item 692
        gen::add_line result $exit_door $base 0
    } else {
        
    }
    #item 280
    return $result
}

proc goto { text } {
    #item 658
    return "goto $text;"
}

proc guard_name { filename } {
    #item 499
    set tail [ file tail $filename ]
    set no_dots [ string map { "." "_" "-" "_" } $tail ]
    set random [ expr { int(rand() * 100000) } ]
    append no_dots $random
    set guard [ string toupper $no_dots ]
    #item 502
    return $guard
}

proc highlight { tokens } {
    #item 680
    variable keywords
    #item 681
    return [ gen_cs::highlight_generic $keywords $tokens ]
}

proc if_end { } {
    #item 640
    return "\) \{"
}

proc if_start { } {
    #item 636
    return "if \("
}

proc label_name { item_id } {
    #item 478
    return "item_$item_id"
}

proc p.add_block { output text base jump_item next_item_id items i callbacks } {
    #item 447
    upvar 1 $output result
    #item 441
    if {$text == ""} {
        #item 446
        set has_text 0
    } else {
        #item 442
        gen::add_lines result "" $text "" $base 1
        set has_text 1
    }
    #item 445
    p.jump result $jump_item $base 1 \
    $next_item_id $has_text $items $i \
    $callbacks
}

proc p.and { left right } {
    #item 595
    return "($left) && ($right)"
}

proc p.generate_action { output links text base next_item_id items i callbacks } {
    #item 453
    upvar 1 $output result
    #item 455
    incr base -1
    #item 456
    set link [ lindex $links 0 ]
    set dst_item [ lindex $link 0 ]
    #item 454
    p.add_block result $text $base $dst_item $next_item_id $items $i \
    $callbacks
}

proc p.generate_if { output links text b base next_item_id items i callbacks } {
    #item 394
    upvar 1 $output result
    #item 631
    set if_start [ gen::get_callback $callbacks if_start ]
    set if_end [ gen::get_callback $callbacks if_end ]
    set else_start [ gen::get_callback $callbacks else_start ]
    set block_close [ gen::get_callback $callbacks block_close ]
    #item 386
    if {$b == 1} {
        #item 387
        set then_index 0
        set else_index 1
    } else {
        #item 388
        set then_index 1
        set else_index 0
    }
    #item 391
    unpack [ lindex $links $then_index ] then_item foo then_code
    unpack [ lindex $links $else_index ] else_item foo else_code
    #item 632
    set if_s [ $if_start ]
    set if_n [ $if_end ]
    set else_s [ $else_start ]
    set bc [ $block_close ]
    #item 392
    gen::add_lines result \
    $if_s $text $if_n $base 0
    #item 395
    p.add_block result $then_code $base $then_item $next_item_id \
    $items $i $callbacks
    #item 393
    gen::add_line result $else_s $base 0
    #item 396
    p.add_block result $else_code $base $else_item $next_item_id \
    $items $i $callbacks
    #item 398
    gen::add_line result $bc $base 0
}

proc p.jump { output item_id base depth next_item_id has_text items i callbacks } {
    #item 687
    variable exit_jump
    #item 360
    upvar 1 $output result
    #item 661
    set goto [ gen::get_callback $callbacks goto ]
    set return_none [ gen::get_callback $callbacks return_none ]
    #item 662
    set returns [ $return_none ]
    #item 3490001
    if {$item_id == "last_item"} {
        #item 683
        set last [ llength $items ]
        incr last -1
        #item 684
        if {$i == $last} {
            
        } else {
            #item 688
            set exit_jump 1
            #item 690
            set label [ label_name $item_id ]
            set g_op [ $goto "exit_door" ]
            #item 691
            gen::add_line result $g_op $base $depth
        }
    } else {
        #item 3490002
        if {($item_id == $next_item_id) || ($item_id == "has_return")} {
            
        } else {
            #item 372
            set label [ label_name $item_id ]
            set g_op [ $goto $label ]
            #item 663
            gen::add_line result $g_op $base $depth
        }
    }
}

proc p.not { operand } {
    #item 607
    return "!($operand)"
}

proc p.or { left right } {
    #item 603
    return "($left) || ($right)"
}

proc print_c { header_filename fhandle public static header footer } {
    #item 204
    put_credits $fhandle
    #item 205
    set header_tail [ file tail $header_filename ]
    puts $fhandle "#include \"$header_tail\""
    #item 206
    puts $fhandle ""
    puts $fhandle $header
    foreach function $static {
        #item 217
        print_function $fhandle $function 1
    }
    foreach function $static {
        #item 209
        print_function $fhandle $function 0
    }
    foreach function $public {
        #item 221
        print_function $fhandle $function 0
    }
    #item 210
    puts $fhandle $footer
    #item 211
    puts $fhandle ""
}

proc print_function { fhandle function declaration } {
    #item 229
    unpack $function diagram_id name signature body
    #item 228
    unpack $signature type access parameters returns
    set param_names {}
    foreach parameter $parameters {
        #item 235
        set pname [ lindex $parameter 0 ]
        lappend param_names $pname
    }
    #item 503
    set param_count [ llength $param_names ]
    #item 243
    puts -nonewline $fhandle "$returns $name\("
    #item 244
    if {$param_count == 0} {
        #item 246
        puts -nonewline $fhandle "void\)"
    } else {
        #item 249
        puts $fhandle ""
        #item 2480001
        set i 0
        while { 1 } {
            #item 2480002
            if {$i < $param_count} {
                
            } else {
                break
            }
            #item 504
            set parameter [ lindex $param_names $i ]
            #item 250
            puts -nonewline $fhandle "    $parameter"
            #item 505
            if {$i == $param_count - 1} {
                #item 507
                puts $fhandle ""
            } else {
                #item 506
                puts $fhandle ","
            }
            #item 2480003
            incr i
        }
        #item 251
        puts -nonewline $fhandle "\)"
    }
    #item 252
    if {$declaration} {
        #item 254
        puts $fhandle ";"
    } else {
        #item 253
        puts $fhandle " \{"
        #item 230
        set body_lines [ gen::indent $body 1 ]
        #item 231
        puts $fhandle $body_lines
        #item 260
        puts $fhandle "\}"
    }
    #item 259
    puts $fhandle ""
}

proc print_header { filename fhandle functions header footer } {
    #item 181
    put_credits $fhandle
    #item 171
    set guard [ guard_name $filename ]
    #item 182
    puts $fhandle "#ifndef $guard"
    puts $fhandle "#define $guard"
    #item 183
    puts $fhandle ""
    puts $fhandle $header
    foreach function $functions {
        #item 186
        print_function $fhandle $function 1
    }
    #item 187
    puts $fhandle $footer
    #item 188
    puts $fhandle "#endif"
    puts $fhandle ""
}

proc print_switches { output node_list } {
    #item 558
    upvar 1 $output result
    array set nodes $node_list
    foreach item_id [ array names nodes ] {
        #item 561
        set node $nodes($item_id)	
        unpack $node body links
        unpack $body type text b
        #item 562
        if {$type == "select"} {
            #item 565
            set var [ switch_var $item_id ]
            lappend result "int $var;"
        } else {
            
        }
    }
}

proc put_credits { fhandle } {
    #item 180
    set version [ version_string ]
    puts $fhandle \
        "/* Autogenerated with DRAKON Editor $version */"
}

proc return_none { } {
    #item 654
    return "return;"
}

proc shelf { primary secondary } {
    #item 669
    return "$secondary = $primary;"
}

proc switch_var { item_id } {
    #item 483
    return "_sw_$item_id"
}

proc tag { text } {
    #item 627
    return "$text :"
}

}
