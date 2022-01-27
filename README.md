<p align="center">
    <img src="logo.png" width="400" max-width="90%" alt="Syntax" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <a href="https://twitter.com/nerdsupremacist">
        <img src="https://img.shields.io/badge/twitter-@nerdsupremacist-blue.svg?style=flat" alt="Twitter: @nerdsupremacist" />
    </a>
</p>


# Valid

Input Validation Done Right. Have you ever struggled with a website with strange password requirements. 
Especially those crazy weird ones where they tell you whats wrong with your password one step at a time.  And it like takes forever.
Well I have. And to prove a point, and, to be honest, mainly as a joke, I coded a DSL for password requirements.
After a while I decided to make it more generic, and here is the version that can validate any input. 
And I called it Valid.

Valid is a Swift DSL (much like SwiftUI) for validating inputs. It follows Allow or Deny rules, a concept commonly used in access control systems.  

# Installation
### Swift Package Manager

You can install Valid via [Swift Package Manager](https://swift.org/package-manager/) by adding the following line to your `Package.swift`:

```swift
import PackageDescription

let package = Package(
    [...]
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/Valid.git", from: "1.0.0")
    ]
)
```

## Usage

So what can you validate with Valid? Well pretty much anything you'd like. You can use it to:
- Validate Password Requirements
- Privacy and Access Control Checks
- well, I honestly haven't thought of more easy to explain examples, but the possibilities are endless...

Let's start with an example. Let's start validating some passwords. For that we create a Validator, with a set of rules:

```swift
struct PasswordValidator: Validator {
    var rules: ValidationRules<String> {
        AlwaysAllow<String>()
    }
}
```

Right now our validator, just allows every password to be set. That's what AlwaysAllow will do. That will be our fallback. Next we can start with a simple check for the length. Let's say we want it to be at least 8 characters long:

```swift
struct PasswordValidator: Validator {
    var rules: ValidationRules<String> {
        DenyIf("Must contain at least 8 characters") { $0.count < 8 }
        
        AlwaysAllow<String>()
    }
}
```

We just used the DenyIf rule. This rule says that we will deny the input, when our closure evaluates to true. 
But in Valid you can write composable and reusable rules. And you can reuse rules for the values of properties. 
So for example another way of writing the 8 Characters rule would be:

```swift
struct PasswordValidator: Validator {
    var rules: ValidationRules<String> {
        Property(\String.count) {
            DenyIfTooSmall(minimum: 8, message: "Must be at least 8 characters long")
        }
        
        AlwaysAllow<String>()
    }
}
```

The Property struct let's you inline rules for the value of a keypath. And since Valid already has a DenyIfTooSmall rule, we can just reuse it here. 
Let's keep going. How about validating against invalid characters. Well we already included a rule for that:

```swift
struct PasswordValidator: Validator {
    var rules: ValidationRules<String> {
        DenyIfContainsInvalidCharacters(allowedCharacters: .letters.union(.decimalDigits).union(.punctuationCharacters))
        
        Property(\String.count) {
            DenyIfTooSmall(minimum: 8, message: "Must be at least 8 characters long")
        }
        
        AlwaysAllow<String>()
    }
}
```

We can even tell the user which characters are wrong:

```swift
struct PasswordValidator: Validator {
    var rules: ValidationRules<String> {
        DenyIfContainsInvalidCharacters(allowedCharacters: .letters.union(.decimalDigits).union(.punctuationCharacters))
            .withMessage { invalidCharacters in
                let listed = invalidCharacters.map { "\"\($0)\"" }.joined(separator: ", ")
                // Feel free to do better localization and plural handling
                return "Character(s) \(listed) is/are not allowed"
            }
        
        Property(\String.count) {
            DenyIfTooSmall(minimum: 8, message: "Must be at least 8 characters long")
        }
        
        AlwaysAllow<String>()
    }
}
```

Or the classic, your password must contain a number:

```swift
struct PasswordValidator: Validator {
    var rules: ValidationRules<String> {
        DenyIfContainsInvalidCharacters(allowedCharacters: .letters.union(.decimalDigits).union(.punctuationCharacters))
            .withMessage { invalidCharacters in
                let listed = invalidCharacters.map { "\"\($0)\"" }.joined(separator: ", ")
                // Feel free to do better localization and plural handling
                return "Character(s) \(listed) is/are not allowed"
            }
            
        DenyIfContainsTooFewCharactersFromSet(.decimalDigits, minimum: 1, message: "Must contain a number")
        
        Property(\String.count) {
            DenyIfTooSmall(minimum: 8, message: "Must contain a number")
        }
        
        AlwaysAllow<String>()
    }
}
```

In order to use the validator we can just use the function validate:

```swift
// We set lazy to false, which will run all rules to give us more detailed results
let validation = await PasswordValidator().validate(input: "h⚠️llo", lazy: false)
print(validation.verdict) 
// .deny(message: "Character(s) @ is/are not allowed")

let errors = validation.all.errors.map(\.message) 
// ["Character(s) ⚠️ is/are not allowed", "Must contain a number", "Must contain a number"]
```

A couple of details you might have gotten from this:
- Validation works using async/await. This is to enable these rules to perform complex logic such as accessing a database if needed
- Validation is lazy by default. Meaning it will evaluate the rules from top to bottom until it reaches a decision. With the lazy flag set to false, it will evaluate every rule regardless of any final results that came before and report all errors that could occurr. A Password Validator is a perfect opportunity for using this.
- The validation result will include every message that passed or failed during validation

If all you care about is the true or false there's also `isValid`:

```
let isValid = await PasswordValidator().isValid(input: password)
```

### Implementing Rules

So Validators use Rules. These Rules in general can be any of the following:
- Maybe Allow: it will either allow the input or skip to the next rule on the list
- Maybe Deny: it will either deny the input or skip.
- Warning Emmitter: it can add a warning to the results, but will not affect the outcome
- Final Rule: it will either allow or deny. There can't be a rule afer that

There's a protocol for each of these kinds of rules. 
For example, if you were using the Password validator in a Vapor App, and wanted to stop validating passwords during development:

```swift
struct AllowIfInDevelopmentEnvironment<Input>: MaybeAllowValidationRule {
    let app: App

    func evaluate(on input: Input) async -> MaybeAllow {
        if case .development = app.environment {
            return .allow(message: "No checks during development")
        }

        return .skip
    }
}

struct PasswordValidator: Validator {
    let app: App
    
    var rules: ValidationRules<String> {
       AllowIfInDevelopmentEnvironment<String>(app: app)
       
       ...
    }
}
```

The process is very similar for all other kinds of rules. And if you don't feel like writing a struct for your rules, you will always have our defaults:
- AllowIf: Allow if the closure you give it evaluates to true
- DenyIf: Deny if the closure you give it evaluates to true
- WarnIf: Emit a warning if the closure you give it evaluates to true
- AlwaysAllow: Finish the validation by allowing
- AlwaysDeny: Finish the validation by denying

### Validators vs Partial Validators

For the sake of reusability, there's two kinds of validators:
- Regular Validators: Validate the input using the rules. They are guaranteed to finish with a result, either allow or deny. This is enforced at compile time.
- Partial Validators: They are not guaranteed to have a final result.

What does that mean? Well it means that a Validator, needs to have a allow or deny decision at the end. No exceptions. This means that the last rule, needs to be either:
- AlwaysAllow
- AlwaysDeny
- Some implementation of FinalRule
- Another Validator that is guaranteed to finish

On the other hand, Partial Validators are not allowed to include these rules inside.
This effectively means:
- You can inline a partial validator inside any other partial validator or validator. No problem
- You can only inline a validator at the very end of another validator

Did that make sense? No worries, just try it out, you'll get it.

### Debugging and nerdy details

Do you have a tricky input you want to debug? No problem. There's a `checks` function that will tell you exactly all the steps taken by your validator. 
Every allow, deny, skip decision including the location in code where that decision was made:

```swift
let checks = await PasswordValidator().checks(input: "hello", lazy: true)
// [
//    Check(type: DenyIfContainsInvalidCharacters, kind: .validation(.skip), location: ...), 
//    Check(type: DenyIfContainsTooFewCharactersFromSet, kind: .validation(.deny(message: "Must contain a number"), location: ...),
// ]
```

## Contributions
Contributions are welcome and encouraged!

## License
Valid is available under the MIT license. See the LICENSE file for more info.
