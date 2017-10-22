namespace eval sma {

variable g_last_used
set g_last_used 0


variable g_visited
array set g_visited {}

# Autogenerated with DRAKON Editor 1.29

proc add_change_state { gdb new_diagram vertex_id last end callbacks prev_new } {
    #item 778
    set change_state [ gen::get_callback $callbacks \
     "change_state" ]
    set fsm_merge [ gen::get_callback $callbacks \
     "fsm_merge" ]
    #item 626
    set target [ get_text $gdb $vertex_id ]
    #item 788
    if {$fsm_merge} {
        #item 808
        set prev [ get_previous $gdb $vertex_id ]
        #item 809
        if {[ llength $prev ] > 1} {
            #item 812
            bad_vertex $gdb $vertex_id \
             "There must be an 'action' icon with final state."
        } else {
            #item 821
            lassign \
            [get_type_text $gdb $prev] \
            type text
            #item 822
            if {$type == "action"} {
                #item 824
                set text [ string trim $text ]
                #item 823
                if {$text == ""} {
                    #item 812
                    bad_vertex $gdb $vertex_id \
                     "There must be an 'action' icon with final state."
                } else {
                    #item 829
                    if {$target == $last} {
                        #item 832
                        register_last
                        #item 833
                        set text [ $change_state $text "" ]
                    } else {
                        #item 828
                        set text [ $change_state $text $target ]
                    }
                    #item 840
                    set_text $gdb $prev_new $text
                    #item 841
                    return $end
                }
            } else {
                #item 812
                bad_vertex $gdb $vertex_id \
                 "There must be an 'action' icon with final state."
            }
        }
    } else {
        #item 871
        set diagram_id [ $gdb onecolumn {
        	select diagram_id
        	from vertices
        	where vertex_id = :vertex_id
        } ]
        set dname [ diagram_name $gdb $diagram_id ]
        #item 791
        if {$target == $last} {
            #item 794
            register_last
            #item 795
            set text [ $change_state "" $dname ]
        } else {
            #item 790
            set text [ $change_state $target $dname ]
        }
        #item 797
        set item_id [ get_item $gdb $vertex_id ]
        #item 796
        set new_vertex [ gen::p.insert_vertex \
         $gdb $new_diagram $item_id "action" $text "" 0 ]
        #item 844
        connect $gdb $new_vertex $end 1
        #item 843
        return $new_vertex
    }
}

proc all_start_with_receive { gdb diagram_id } {
    #item 270
    set headers [ get_headers $gdb $diagram_id ]
    #item 271
    set count [ llength $headers ]
    #item 272
    set last \
    [expr {$count - 1}]
    #item 2820001
    set i 0
    while { 1 } {
        #item 2820002
        if {$i < $last} {
            
        } else {
            #item 294
            set last_header [ lindex $headers $last ]
            #item 295
            if {[starts_with_receive $gdb $last_header]} {
                #item 299
                bad_vertex $gdb $header \
                 "Exit branch should not start with a 'receive'."
                #item 298
                set result 0
            } else {
                #item 300
                set result 1
            }
            break
        }
        #item 284
        set header [ lindex $headers $i ]
        #item 289
        if {[starts_with_receive $gdb $header]} {
            
        } else {
            #item 293
            bad_vertex $gdb $header \
             "State branch should start with a 'receive'."
            #item 292
            set result 0
            break
        }
        #item 2820003
        incr i
    }
    #item 288
    return $result
}

proc bad_diagram { diagram_id message } {
    #item 309
    gen::report_error $diagram_id "" $message
}

proc bad_vertex { gdb vertex_id message } {
    #item 315
    lassign [ $gdb eval {
    	select item_id, diagram_id
    	from vertices
    	where vertex_id = :vertex_id
    } ] items diagram_id
    #item 316
    gen::report_error $diagram_id $items $message
}

proc build_good_default { } {
    
}

proc build_machine { gdb diagram_id callbacks } {
    #item 164
    clear_last
    #item 262
    set receives [ get_receives $gdb $diagram_id ]
    #item 263
    if {$receives == {}} {
        #item 264
        bad_diagram $diagram_id \
         "No 'receive' statements found."
    } else {
        #item 165
        if {(([has_branches $gdb $diagram_id]) && ([receives_are_first $gdb $receives])) && ([all_start_with_receive $gdb $diagram_id])} {
            #item 344
            set parameters [ get_params_text $gdb $diagram_id ]
            #item 352
            set headers [ get_headers $gdb $diagram_id ]
            set state_headers [ lrange $headers 0 end-1 ]
            set last_branch [ lindex $headers end ]
            set last_name [ get_text $gdb $last_branch ]
            set comments [ get_comments $gdb $diagram_id ]
            #item 353
            set message_types [ find_message_types $gdb $state_headers ]
            set state_names {}
            #item 755
            set boiler {}
            foreach header $state_headers {
                #item 754
                lassign \
                [create_sub_diagrams $gdb $diagram_id $header $message_types \
                 $parameters $last_name $callbacks] \
                state good bad
                #item 756
                lappend boiler $state \
                 [ list "good" $good "bad" $bad ]
                lappend state_names $state
            }
            #item 882
            set last_header [ lindex $headers end ]
            #item 883
            build_sub_diagram \
            	$gdb \
            	$diagram_id \
            	"" \
            	$last_header \
            	$parameters \
            	$last_branch \
            	$callbacks \
            	0
        } else {
            
        }
    }
    #item 757
    set last [ is_last_used ]
    #item 766
    set param_names [ get_param_names $parameters ]
    #item 870
    set dia_name [ diagram_name $gdb $diagram_id ]
    #item 758
    return [ list "last" $last "boiler" $boiler \
     "states" $state_names "messages" $message_types \
     "parameters" $parameters "param_names" $param_names \
     "name" $dia_name "comments" $comments ]
}

proc build_sub_diagram { gdb diagram_id state case parameters last_branch callbacks ordinal } {
    #item 528
    set message [ get_text $gdb $case ]
    #item 884
    if {$state == ""} {
        #item 887
        set name "CleanUp"
        set default 0
    } else {
        #item 529
        if {$message == ""} {
            #item 532
            set name "${state}_default"
            set default 1
        } else {
            #item 878
            set message2 [ string map { - _ . _ } $message ]
            #item 524
            set name "${state}_${message2}"
            set default 0
        }
    }
    #item 525
    set private { "private" }
    set signature [ concat $private $parameters ]
    #item 527
    set param_text [ join $signature "\n" ]
    #item 699
    set first [ gen::p.get_following $gdb $case ]
    #item 869
    set original [ diagram_name $gdb $diagram_id ]
    #item 533
    set end_item [ find_end $gdb $diagram_id ]
    #item 698
    set new_diagram [ make_diagram $gdb $name $param_text ]
    enrich_diagram $gdb $new_diagram \
     $state $message $ordinal $default $original
    #item 660
    set end_vertex [ gen::p.insert_vertex \
     $gdb $new_diagram $end_item "beginend" "End" "" 0 ]
    #item 547
    clear_visited
    #item 703
    set new_first \
    [copy_vertexes $gdb $new_diagram $first \
     $last_branch $end_vertex $callbacks ""]
    #item 702
    set_first_icon $gdb $new_diagram $new_first
    #item 738
    #print_diagram $gdb $new_diagram
}

proc clear_last { } {
    #item 764
    variable g_last_used
    #item 765
    set g_last_used 0
}

proc clear_visited { } {
    #item 564
    variable g_visited
    #item 565
    array unset g_visited
    array set g_visited {}
}

proc connect { gdb src dst ordinal } {
    #item 616
    gen::p.link $gdb $src $ordinal $dst
}

proc copy_vertex { gdb new_diagram vertex_id } {
    #item 617
    lassign [ $gdb eval {
    	select type, text, text2, item_id, b
    	from vertices
    	where vertex_id = :vertex_id
    } ] type text text2 item_id b
    #item 618
    set new_vertex [ gen::p.insert_vertex \
     $gdb $new_diagram $item_id $type $text $text2 $b ]
    #item 619
    return $new_vertex
}

proc copy_vertexes { gdb new_diagram vertex_id last end callbacks prev_new } {
    #item 541
    if {[is_visited $vertex_id]} {
        #item 549
        set new_vertex [ get_new_vertex_id $vertex_id ]
    } else {
        #item 540
        if {[is_address $gdb $vertex_id]} {
            #item 551
            set new_vertex \
            [add_change_state $gdb $new_diagram $vertex_id \
             $last $end $callbacks $prev_new]
        } else {
            #item 559
            set new_vertex [ copy_vertex $gdb $new_diagram $vertex_id ]
            #item 715
            visit $vertex_id $new_vertex
            #item 553
            set next [ find_next $gdb $vertex_id ]
            set i 1
            foreach next_vertex $next {
                #item 558
                set new_next \
                [copy_vertexes $gdb $new_diagram $next_vertex \
                 $last $end $callbacks $new_vertex]
                #item 557
                connect $gdb $new_vertex $new_next $i
                #item 556
                incr i
            }
        }
    }
    #item 550
    return $new_vertex
}

proc create_sub_diagrams { gdb diagram_id header message_types parameters last_branch callbacks } {
    #item 493
    set state [ get_text $gdb $header ]
    #item 486
    set select [ gen::p.get_next $gdb $header 1 ]
    #item 485
    set types [ message_types_for_select $gdb $select ]
    #item 489
    set has_default [ contains $types "" ]
    #item 494
    set redirected {}
    foreach common_type $message_types {
        #item 490
        if {[contains $types $common_type]} {
            
        } else {
            #item 495
            lappend redirected $common_type
        }
    }
    #item 526
    set next [ find_next $gdb $select ]
    set i 0
    foreach case $next {
        #item 502
        build_sub_diagram $gdb $diagram_id $state $case \
         $parameters $last_branch $callbacks $i
        #item 845
        incr i
    }
    #item 503
    if {$redirected == {}} {
        #item 753
        set bad {}
        set good {}
    } else {
        #item 748
        set methods $redirected
        #item 506
        if {$has_default} {
            #item 752
            set bad {}
            set good $methods
        } else {
            #item 509
            set bad $methods
            set good {}
        }
    }
    #item 747
    return [ list $state $good $bad ]
}

proc delete_diagram { gdb diagram_id } {
    #item 145
    $gdb eval {
    	delete from branches 
    	where diagram_id = :diagram_id;
    
    	delete from diagrams
    	where diagram_id = :diagram_id;
    }
}

proc diagram_name { gdb diagram_id } {
    #item 107
    set name [ $gdb onecolumn {
    	select name
    	from diagrams
    	where diagram_id = :diagram_id } ]
    #item 108
    return $name
}

proc enrich_diagram { gdb diagram_id state message ordinal is_default original } {
    #item 851
    $gdb eval {
    	update diagrams
    	set state = :state,
    	message_type = :message,
    	ordinal = :ordinal,
    	is_default = :is_default,
    	original = :original
    	where diagram_id = :diagram_id
    }
}

proc extract_machine { gdb callbacks } {
    #item 132
    set diagrams [ $gdb eval {
    	select diagram_id from diagrams } ]
    foreach diagram_id $diagrams {
        #item 135
        if {[graph::is_machine $diagram_id]} {
            #item 148
            set info [ build_machine $gdb $diagram_id $callbacks ]
            #item 147
            delete_diagram $gdb $diagram_id
            #item 139
            return $info
        } else {
            
        }
    }
    #item 138
    return {}
}

proc extract_many_machines { gdb callbacks } {
    #item 867
    set result {}
    #item 857
    set diagrams [ $gdb eval {
    	select diagram_id from diagrams } ]
    foreach diagram_id $diagrams {
        #item 860
        if {[graph::is_machine $diagram_id]} {
            #item 866
            set info [ build_machine $gdb $diagram_id $callbacks ]
            #item 865
            delete_diagram $gdb $diagram_id
            #item 864
            lappend result $info
        } else {
            
        }
    }
    #item 868
    return $result
}

proc find_end { gdb diagram_id } {
    #item 659
    $gdb eval {
    	select item_id, text
    	from vertices
    	where diagram_id = :diagram_id
    } {
    	if { [ graph::p.is_end $text ] } {
    		return $item_id
    	}
    }
    
    error "End not found."
}

proc find_message_types { gdb headers } {
    #item 465
    set all_types {}
    foreach header $headers {
        #item 467
        set select [ gen::p.get_next $gdb $header 1 ]
        #item 464
        set types [ message_types_for_select $gdb $select ]
        #item 470
        set wo_default [ filter2 $types not_empty ]
        #item 466
        set all_types [ concat $all_types $wo_default ]
    }
    #item 468
    set result [ lsort -unique $all_types ]
    #item 469
    return $result
}

proc find_next { gdb vertex } {
    #item 603
    set result {}
    set i 1
    while { 1 } {
        #item 599
        set dst [ gen::p.get_next $gdb $vertex $i ]
        #item 600
        if {$dst == ""} {
            break
        } else {
            
        }
        #item 604
        incr i
        lappend result $dst
    }
    #item 605
    return $result
}

proc get_comments { gdb diagram_id } {
    #item 877
    return [ $gdb eval {
    	select text
    	from items
    	where diagram_id = :diagram_id
    	and type = 'commentin'
    	and text is not null
    } ]
}

proc get_headers { gdb diagram_id } {
    #item 350
    set headers [ $gdb eval {
    	select header_icon
    	from branches
    	where diagram_id = :diagram_id
    	order by ordinal } ]
    #item 351
    return $headers
}

proc get_item { gdb vertex_id } {
    #item 638
    set value [ $gdb onecolumn {
    	select item_id
    	from vertices
    	where vertex_id = :vertex_id } ]
    #item 639
    return $value
}

proc get_new_vertex_id { vertex_id } {
    #item 578
    variable g_visited
    #item 579
    return $g_visited($vertex_id)
}

proc get_param_names { parameters } {
    #item 772
    set result {}
    foreach par $parameters {
        #item 776
        set parts [ split $par " \t" ]
        set last [ lindex $parts end ]
        #item 777
        lappend result $last
    }
    #item 773
    return $result
}

proc get_params_text { gdb diagram_id } {
    #item 322
    lassign [ gen::get_diagram_start $gdb $diagram_id ] \
     start params_icon
    #item 323
    if {$params_icon == {}} {
        #item 333
        return {}
    } else {
        #item 325
        set text [ gen::p.vertex_text $gdb $params_icon ]
        #item 327
        if {$text == ""} {
            #item 333
            return {}
        } else {
            #item 326
            set lines [ split $text "\n" ]
            #item 330
            set result {}
            foreach line $lines {
                #item 334
                set trimmed [ string trim $line ]
                #item 335
                if {(($trimmed == "") || ([string match "#*" $trimmed])) || ([string match "//*" $trimmed])} {
                    
                } else {
                    #item 340
                    lappend result $trimmed
                }
            }
            #item 332
            return $result
        }
    }
}

proc get_previous { gdb vertex_id } {
    #item 807
    return [ $gdb eval {
    		select src
    		from links
    		where dst = :vertex_id } ]
}

proc get_receives { gdb diagram_id } {
    #item 252
    set vertexes [ $gdb eval {
    	select vertex_id
    	from vertices
    	where diagram_id = :diagram_id } ]
    #item 254
    set result {}
    foreach vertex_id $vertexes {
        #item 258
        if {[is_receive $gdb $vertex_id]} {
            #item 261
            lappend result $vertex_id
        } else {
            
        }
    }
    #item 255
    return $result
}

proc get_text { gdb vertex_id } {
    #item 592
    set text [ $gdb onecolumn {
    	select text
    	from vertices
    	where vertex_id = :vertex_id } ]
    #item 593
    return $text
}

proc get_type_text { gdb vertex_id } {
    #item 819
    set value [ $gdb eval {
    	select type, text
    	from vertices
    	where vertex_id = :vertex_id } ]
    #item 820
    return $value
}

proc has_branches { gdb diagram_id } {
    #item 114
    set count [ $gdb onecolumn {
    	select count(*)
    	from branches
    	where diagram_id = :diagram_id } ]
    #item 115
    if {$count > 1} {
        #item 169
        return 1
    } else {
        #item 118
        set name [ diagram_name $gdb $diagram_id ]
        #item 119
        bad_diagram $diagram_id \
         "Diagram '$name' is a state machine and must be a silhouette."
        #item 168
        return 0
    }
}

proc insert_vertex { gdb diagram_id type text } {
    #item 688
    set vertex_id [ mod::next_key $gdb vertices vertex_id ]
    #item 691
    set item_id [ mod::next_key $gdb vertices item_id ]
    #item 689
    $gdb eval {
    	insert into vertices
    		(vertex_id, diagram_id, type, text, marked, item_id )
    	values  (:vertex_id, :diagram_id, :type, :text, 0, :item_id)
    }
    #item 690
    return $vertex_id
}

proc is_address { gdb vertex_id } {
    #item 713
    set type [ $gdb onecolumn {
    	select type
    	from vertices
    	where vertex_id = :vertex_id
    } ]
    #item 714
    return [ expr { $type == "address" } ]
}

proc is_from_machine { gdb diagram_id } {
    #item 893
    set original [ $gdb onecolumn {
    	select original
    	from diagrams
    	where diagram_id = :diagram_id
    } ]
    #item 894
    if {$original == ""} {
        #item 895
        return 0
    } else {
        #item 896
        return 1
    }
}

proc is_last_used { } {
    #item 651
    variable g_last_used
    #item 652
    return $g_last_used
}

proc is_receive { gdb vertex_id } {
    #item 213
    lassign [ $gdb eval {
    	select type, text
    	from vertices
    	where vertex_id = :vertex_id } ] type text
    #item 214
    if {(($type == "action") || ($type == "select")) && ($text == "receive")} {
        #item 218
        return 1
    } else {
        #item 219
        return 0
    }
}

proc is_visited { vertex_id } {
    #item 569
    variable g_visited
    #item 570
    return [ info exists g_visited($vertex_id) ]
}

proc make_diagram { gdb name params } {
    #item 675
    set diagram_id [ mod::next_key $gdb diagrams diagram_id ]
    #item 677
    $gdb eval {
    	insert into diagrams (diagram_id, name)
    	values (:diagram_id, :name) }
    #item 678
    set start_icon [ insert_vertex $gdb $diagram_id "beginend" $name ]
    #item 679
    set params_icon [ insert_vertex $gdb $diagram_id "action" $params ]
    #item 680
    $gdb eval {
    	insert into branches
    		(diagram_id, ordinal, start_icon, params_icon)
    	values (:diagram_id, 1, :start_icon, :params_icon)
    }
    #item 676
    return $diagram_id
}

proc message_types_for_select { gdb select } {
    #item 408
    set next [ find_next $gdb $select ]
    #item 409
    set result {}
    foreach case $next {
        #item 413
        set text [ get_text $gdb $case ]
        #item 417
        lappend result $text
    }
    #item 410
    return $result
}

proc previous_is_header { gdb vertex_id } {
    #item 244
    set previous [ $gdb onecolumn {
    	select src
    	from links
    	where dst = :vertex_id
    	and ordinal = 1 } ]
    #item 245
    set type [ $gdb onecolumn {
    	select type
    	from vertices
    	where vertex_id = :previous } ]
    #item 302
    if {$type == "branch"} {
        #item 246
        return 1
    } else {
        #item 305
        return 0
    }
}

proc print_diagram { gdb diagram_id } {
    #item 735
    set name [ diagram_name $gdb $diagram_id ]
    set first_icon [ $gdb onecolumn {
    	select first_icon
    	from branches
    	where diagram_id = :diagram_id
    	and ordinal = 1 } ]
    #item 736
    puts "======================="
    puts $name
    #item 734
    clear_visited
    #item 737
    print_vertex $gdb $first_icon
}

proc print_vertex { gdb vertex_id } {
    #item 726
    if {[is_visited $vertex_id]} {
        
    } else {
        #item 729
        visit $vertex_id 0
        #item 730
        lassign [ $gdb eval {
        	select item_id, type, text, text2
        	from vertices
        	where vertex_id = :vertex_id
        } ] item_id type text text2
        #item 731
        puts "$vertex_id: item_id=$item_id type=$type text:\n$text\n text2=$text2"
        #item 732
        set next [ find_next $gdb $vertex_id ]
        #item 733
        puts "  $next"
        foreach next_id $next {
            #item 741
            print_vertex $gdb $next_id
        }
    }
}

proc receives_are_first { gdb receives } {
    foreach receive $receives {
        #item 234
        if {[ previous_is_header $gdb $receive ]} {
            
        } else {
            #item 306
            bad_vertex $gdb $receive \
             "A 'receive' icon must be first in the branch."
            #item 308
            return 0
        }
    }
    #item 307
    return 1
}

proc register_last { } {
    #item 646
    variable g_last_used
    #item 647
    set g_last_used 1
}

proc set_first_icon { gdb diagram_id vertex_id } {
    #item 707
    set start_icon [ $gdb onecolumn {
    	select start_icon
    	from branches
    	where diagram_id = :diagram_id
    	and ordinal = 1
    } ]
    #item 697
    $gdb eval {
    	update branches
    	set first_icon = :vertex_id
    	where diagram_id = :diagram_id
    	and ordinal = 1
    }
    #item 706
    gen::p.link $gdb $start_icon 1 $vertex_id
}

proc set_text { gdb vertex_id text } {
    #item 839
    $gdb eval {
    	update vertices
    	set text = :text
    	where vertex_id = :vertex_id
    }
}

proc starts_with_receive { gdb header } {
    #item 206
    set first [ gen::p.get_next $gdb $header 1 ]
    #item 207
    return [ is_receive $gdb $first ]
}

proc visit { old_vertex new_vertex } {
    #item 585
    variable g_visited
    #item 586
    set g_visited($old_vertex) $new_vertex
}

}
