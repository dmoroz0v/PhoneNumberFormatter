//
//  ViewController.swift
//  PhoneNumberFormatter
//
//  Created by Морозов Денис Сергеевич on 14/11/16.
//  Copyright © 2016 DMZ. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

//	+7 912 345-67-89
//	+39 312 345 6789
	
	@IBOutlet weak var textField: UITextField!

	let formats = [
		"7" : "_(___)___-__-__",
		"37" : "__-___-___-____",
	]

	func textField(_ textField: UITextField,
	               shouldChangeCharactersIn range: NSRange,
	               replacementString string: String) -> Bool
	{
		guard let selectedRange = textField.selectedTextRange else { return false }
		guard var text = textField.text else { return false }

		let oldCursorPositionInFormatted = textField.offset(
			from: textField.beginningOfDocument,
			to: selectedRange.start)

		let oldCursorPositionInRaw = self.cursorPositionInRaw(
			text: text,
			cursorPositionInFormatted: oldCursorPositionInFormatted)

		let newCursorPositionInRaw = oldCursorPositionInRaw + self.filter(text: string).characters.count

		text = text.replacingCharacters(in: text.range(from: range)!, with: string)
		text = self.filter(text: text)
		let result = self.formatted(rawText: text, cursorPositionInRaw: newCursorPositionInRaw)
		textField.text = result.value

		if let newPosition = textField.position(from: textField.beginningOfDocument, offset: result.cursorPosition) {

			textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
		}

		return false
	}

	func formatted(rawText: String, cursorPositionInRaw: Int) -> (value: String, cursorPosition: Int) {
		let format = formats.first { key, _ -> Bool in return rawText.hasPrefix(key) }?.value

		if let format = format {
			var cursorPosition = 0
			var k = 0
			format.characters.forEach {
				if k < cursorPositionInRaw {
					cursorPosition += 1
				}
				if $0 == "_" {
					k += 1
				}
			}
			var i = 0
			let value = String(format.characters.map {
				if $0 != "_" {
					return $0
				} else if i < rawText.characters.count {
					let charAtIndex = rawText[rawText.index(rawText.startIndex, offsetBy: i)]
					i = i + 1
					return charAtIndex
				} else {
					return $0
				}
			})
			return (value, cursorPosition)
		} else {
			return (rawText, cursorPositionInRaw)
		}
	}

	func cursorPositionInRaw(text: String, cursorPositionInFormatted: Int) -> Int {
		let index = text.index(from: cursorPositionInFormatted)!
		let substring = text.substring(to: index)
		let filteredSubstring = self.filter(text: substring)
		return filteredSubstring.characters.count
	}

	func filter(text: String) -> String {
		return text.replacingOccurrences(
			of: "\\D",
			with: "",
			options: .regularExpression,
			range: text.startIndex ..< text.endIndex)
	}
}

extension String {
	func range(from nsRange: NSRange) -> Range<String.Index>? {
		guard
			let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
			let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
			let from = String.Index(from16, within: self),
			let to = String.Index(to16, within: self)
			else { return nil }
		return from ..< to
	}

	func index(from int: Int) -> String.Index? {
		guard
			let index16 = utf16.index(utf16.startIndex, offsetBy: int, limitedBy: utf16.endIndex),
			let index = String.Index(index16, within: self)
			else { return nil }
		return index
	}
}
