module FakeTests

open Xunit
open FsUnit.Xunit
open Fake

[<Fact>]
let ``Single line test code on same line`` () = add 1 1 |> should equal 2

[<Fact>]
let ``Single line test code on next line`` () =
    sub 7 3 |> should equal 4

[<Fact>]
let ``Multiple lines of test code at same indentation`` () =
    let expected = 6
    mul 2 3 |> should equal expected

[<Fact>]
let ``Multiple lines of test code with different indentation`` () =
    let expected = 6
    let actual =
        let x = 2
        let y = 3
        mul x y
    actual |> should equal expected
