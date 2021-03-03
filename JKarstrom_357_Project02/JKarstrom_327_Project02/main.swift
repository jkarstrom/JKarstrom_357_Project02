//
//  main.swift
//  JKarstrom_327_Project02
//  Karstrom@chapman.edu
//  ID: 2318286
//  CPSC-357 iOS Development

import Foundation

var userDictionary = [String:String]()

var reply = ""
var userRequest = ""
var passwordRequest = ""
var keeprunning = true
var masterPassword = ""


class Program
{
    init()
    {
        userDictionary = readJSON()
        print("Welcome!")
        passwordRequest = Ask.AskQuestion(questiontext: "Do you have a master password set? Yes (1) or 2 (no)" , acceptableReplies: ["1","2"])
        let yORn = Int(passwordRequest)
        if yORn == 1
        {
            print("Please input the master password")
            let userInput = readLine()
            masterPassword = userInput!
        }
        else if yORn == 2
        {
            print("Please input a new master password")
            let userInput = readLine()
            masterPassword = userInput!
        }
        else
        {
            print("Invalid input")
        }
        
        while keeprunning
        {
            print("What would you like to do?")
            userRequest = Ask.AskQuestion(questiontext: "View All (1), View Single (2), Delete Single (3), Add Single (4), Exit (0)", acceptableReplies: ["0", "1", "2", "3", "4", "0"])
            let whatCommand = Int(userRequest)
            if whatCommand == 1  // print all of dictionary
            {
                viewAll()
            }
            else if whatCommand == 2 // find and print a singular code
            {
                viewSingle()
            }
            else if whatCommand == 3 // find and delete a code
            {
                deleteSingle()
            }
            else if whatCommand == 4 //add a password
            {
                addSingle()
            }
            else if whatCommand == 0 //exit the program
            {
                keeprunning = false
            }
            else
            {
                print("Invalid input")
            }
        }
        //ask a question, act on it, check if we should keep it running
        //if not, change keepRunning = false Application will end
        writeJSON(existingDict: userDictionary)
        reply = Ask.AskQuestion(questiontext: "Do you want to keep running the app", acceptableReplies: ["no","yes"])
        if reply == "no"
        {
            keeprunning = false
        }
    }
    
    //menu options
    func viewAll()
    {
        for key in userDictionary.keys
        {
            print ("\(key)")
        }
        print("returning to menu")
    }

    func viewSingle()
    {
        print("Input key of password you want to find: ")
        if let userKey = readLine()
        {
            let key = userDictionary[userKey] != nil //finding if password exists
            if key
            {
                print("Enter your passphrase: ")
                let userPassphrase = readLine()
                if userPassphrase == masterPassword
                {
                    print("Password: ")
                    let encrypt = decode(encode: userDictionary[userKey]!) //getting the encrypted password
                    writeJSON(existingDict: userDictionary)
                }
                else
                {
                    print("incorrect master password")
                }
            }
            else
            {
                print("Invalid input, returning to menu")
            }
        }
    }
        
    //ceaser
    func caesarCipher(value: String, shift: Int) -> String
    {
        var charArry = [Character] ()
        for i in value.utf8
        {
            let s = Int(i) + shift
            if s > 97 + 25
            {
                charArry.append(Character(UnicodeScalar(s - 26)!))
            } else if s < 97 {
                charArry.append(Character(UnicodeScalar(s + 26)!))
            } else {
                charArry.append(Character(UnicodeScalar(s)!))
            }
        }
        return String(charArry)
    }
     
    func encode(decode: String) -> String //encoding password
    {
        let reverse = String(decode.reversed()) //reverseing
        return caesarCipher(value: reverse, shift: 8)
    }

    func decode(encode: String)//decoding it back to normal
    {
        let reverse = String(encode.reversed()) //reverse it
        let decode = caesarCipher(value: reverse, shift: 8) //un ceaser cipher it
        let masterPasswordLength = masterPassword.count
        let finPass = decode.count - masterPasswordLength
        if decode.dropFirst(finPass) == masterPassword
        {
            print(String(decode.prefix(finPass)))
        }
        else
        {
            print("Incorrect Passphrase")
        }
    }

    func deleteSingle()
    {
        print("Which password would you like to delete. Please enter the key: ")
        if let key = readLine()
        {
            let keyExists = userDictionary[key] != nil
            if keyExists
            {
                userDictionary[key] = nil
                print("That password was deleted")
                writeJSON(existingDict: userDictionary)
            }
            else
            {
                print("Not a valid key, returning to menu")
            }
        }
    }

    func addSingle()
    {
        print("Input name of password: ")
        let passwordName = readLine()
        print("Input the password to save: ")
        let password : String? = readLine()
        print ("Enter your passphrase: ")
        let userPassphrase : String? = readLine()
        if userPassphrase == masterPassword
        {
            let combine = password! + userPassphrase!
            let final = encode(decode: combine)
            userDictionary[passwordName!] = final
            print("Password has been added")
            writeJSON(existingDict: userDictionary)
        }
        else
        {
            print("wrong master password")
        }
    }

    //JSON THINGS
    func writeJSON(existingDict : Dictionary<String,String> )
    {
        do {
            let fileURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("userPasswords.json")
            try JSONSerialization.data(withJSONObject: userDictionary).write(to: fileURL)
        } catch {
            print(error)
        }
    }

    func readJSON() -> Dictionary<String,String>
    {
        do
        {
            let fileURL = try FileManager.default .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("userPasswords.json")

            let data = try Data(contentsOf: fileURL)
            var dictionary = try JSONSerialization.jsonObject(with: data)
            dictionary = userDictionary
        }
        catch
        {
            print(error)
        }
        return userDictionary
    }
}

class Ask
{
    static func AskQuestion(questiontext output: String, acceptableReplies inputArr: [String], caseSensitive: Bool = false) -> String
    {
        print(output)//ask our question
        //Handel response
        guard let response = readLine() else {
            //they didn't type anything at all
            print("Invalid input")
            return AskQuestion(questiontext: output, acceptableReplies: inputArr)
        }
        
        //they typed in a valid answer: verify the response is acceptable
        //OR that we dont care what the response is
        if(inputArr.contains(response)) || inputArr.isEmpty
        {
            return response
        }
        else
        {
            print("Invalid input")
            return AskQuestion(questiontext: output, acceptableReplies: inputArr)
        }
    }
}

let p = Program()

