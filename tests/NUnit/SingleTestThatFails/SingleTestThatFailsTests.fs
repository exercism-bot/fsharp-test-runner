module SingleTestThatFailsTests

open NUnit.Framework
open FsUnit
open Exercism.Tests
open SingleTestThatFails

[<Test>]
let ``Add should add numbers`` () = add 1 1 |> should equal 3