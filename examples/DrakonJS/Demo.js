// Your code at the beginning of the file.
"use strict;"



function Demo() {



// Autogenerated with DRAKON Editor 1.29


function createBar(left, right) {
    var x, y
    // item 388
    x = left + 10
    y = right + 20
    // item 380
    return {
        left : x,
        right : y
    }
}

function doSomething(first, second, third) {
    var bar, fifth, fourth, i, moo, x37
    // item 369
    fourth = first + second
    fifth = second + 10
    third = third || ""
    // item 372
    x37 = fourth +
     fifth * 3
    // item 371
    moo = {
        x : 10 + Math.cos(first),
        y : 20
    }
    // item 374
    third.z = 30
    // item 370
    bar = createBar(
        first,
        444
    )
    // item 373
    console.log(
        fourth,
        fifth,
        x37,
        moo,
        bar
    )
    // item 3980001
    i = 0;
    while (true) {
        // item 3980002
        if (i < 2) {
            
        } else {
            break;
        }
        // item 400
        console.log(i)
        // item 3980003
        i++;
    }
}

function lambdas() {
    var lam, lam2, lam3, p, someVar
    // item 419
    someVar = 900
    // item 412
    lam = function(left, right) {
        console.log(
            left,
            right,
            someVar
        )
    }
    // item 413
    lam(45, 46)
    // item 414
    lam2 = function(value) {
        return value * 2
    }
    // item 415
    console.log(
        lam2(10)
    )
    // item 416
    lam3 = function() {
        return {
            x : 22,
            y : 33
        }
    }
    // item 417
    p = lam3()
    console.log(p)
}

function main() {
    // item 310
    console.log("hello")
    // item 386
    doSomething(
        100,
        2000,
        {x:60000}
    )
    // item 418
    lambdas()
    // item 387
    console.log("bye")
}


// Your code at the end of the file.

this.main = main

} // End of namespace

// Символы Юникод

var demo = new Demo()
demo.main()
