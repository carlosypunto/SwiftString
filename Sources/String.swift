/*

Erica Sadun, http://ericasadun.com

*/

// --------------------------------------------------
// MARK: Character View
// --------------------------------------------------

public extension String.CharacterView {
    /// Convert character view back to String
    public var stringValue: String {return String(self)}
}

public extension String {
    /// Length in characters
    public var characterLength: Int {return characters.count}
}

// --------------------------------------------------
// MARK: Wackbards
// --------------------------------------------------

public extension String {
    /// Reverse a String instance by re-ordering its characters
    public var reversed: String {return String(characters.reverse())}
}

// --------------------------------------------------
// MARK: Ranges
// --------------------------------------------------

extension String {
    /// Create String range from integer range, using string endIndex limit to guard extent
    public func rangeFromIntegerRange(range: Range<Int>) -> Range<String.Index> {
        let start = startIndex.advancedBy(range.startIndex, limit: endIndex)
        let end = startIndex.advancedBy(range.endIndex, limit: endIndex)
        return start..<end
    }
}

// --------------------------------------------------
// MARK: Range and Components Separated
// --------------------------------------------------

public extension String {
    
    /// Range of first match to string
    public func rangeOfString(searchString: String) -> Range<Index>? {
        
        // If equality, return full range
        if searchString == self {return startIndex..<endIndex}
        
        // Basic sanity checks
        let (count, stringCount) = (characters.count, searchString.characters.count)
        guard !isEmpty && !searchString.isEmpty && stringCount < count else {return nil}
        
        // Moving search offset. Thanks Josh W
        let stringCharacters = characters
        let searchCharacters = searchString.characters
        var searchOffset = stringCharacters.startIndex
        let searchLimit = stringCharacters.endIndex.advancedBy(-stringCount)
        var failedMatch = true
        
        // March character checks through string
        while searchOffset <= searchLimit {
            failedMatch = false
            
            // Enumerate through characters
            for (idx, c) in searchCharacters.enumerate() {
                if c != stringCharacters[searchOffset.advancedBy(idx)] {
                    failedMatch = true; break
                }
            }
            
            // Test for success
            guard failedMatch else {break}
            
            // Offset search by one character
            searchOffset = searchOffset.successor()
        }
        
        return failedMatch ? nil : searchOffset..<searchOffset.advancedBy(stringCount)
    }
    
    /// Mimic NSString's version
    public func componentsSeparatedByString(separator:  String) -> [String] {
        var components: [String] = []
        var searchString = self
        
        // Find a match
        while let range = searchString.rangeOfString(separator) {
            
            // Break off first item (thanks Josh W)
            let searchStringCharacters = searchString.characters
            let first = String(searchStringCharacters.prefixUpTo(range.startIndex))
            if !first.isEmpty {components.append(first)}
            
            // Anything left to find?
            if range.endIndex == searchString.endIndex {
                return components.isEmpty ? [self] : components
            }
            
            // Move past the separator and continue
            searchString = String(searchStringCharacters.suffixFrom(range.endIndex))
        }
        
        if !searchString.isEmpty {
            components.append(searchString)
        }
        return components
    }
}

infix operator ~== {}

/// Public operator for matching. I'm not sure if I'm settled on this
/// implementation yet, so this will be subject to change.
public func ~==(lhs: String, rhs: String) -> Range<String.Index>? {
    return lhs.rangeOfString(rhs)
}

// --------------------------------------------------
// MARK: Decomposition
// --------------------------------------------------

public extension String {
    
    /// First character in the string
    public var first: String {
        return isEmpty ? "" : self[startIndex..<startIndex.successor()]
    }
    
    /// All characters but the first
    public var butFirst: String {
        return String(characters.dropFirst())
    }
    
    /// first alias for Lispies
    public var car: String {return first}
    
    /// butFirst / rest alias for Lispies
    public var cdr: String {return butFirst}

    /// Last character in the string
    public var last: String {
        return isEmpty ? "" : self[endIndex.predecessor()..<endIndex]
    }

    /// All characters but the last
    public var butLast: String {return String(characters.dropLast())}
    
    /// Return string at subrange
    public func just(desiredRange: Range<Int>) -> String {
        let range = rangeFromIntegerRange(desiredRange)
        return self[range]
    }

    /// Return string composed of character at index
    public func at(desiredIndex: Int) -> String {
        return just(desiredIndex...desiredIndex)
    }

    /// Return string excluding range
    public func except(range: Range<Int>) -> String {
        var copy = self
        let range = rangeFromIntegerRange(range)
        copy.replaceRange(range, with:"")
        return copy
    }
}


// --------------------------------------------------
// MARK: Subscripting
// --------------------------------------------------

public extension Int {
    /// Subscript a string using Integer[String] representation
    /// e.g. let c = 4["hello world"] // "o"
    /// Thanks Mike Ash
    public subscript(string: String) -> Character {
        return string[string.startIndex.advancedBy(self)]
    }
}

extension String {
    // The setters in the following two subscript do not enforce length equality
    // You can replace 1...100 with, for example, "foo"

    /// Subscript a String using integer ranges
    public subscript (range: Range<Int>) -> String {
        get {return just(range)}
        set {replaceRange(rangeFromIntegerRange(range), with:newValue ?? "")}
    }
    
    /// Subscript a String using an integer index
    public subscript (i: Int) -> String? {
        get {return at(i)}
        set {replaceRange(rangeFromIntegerRange(i...i), with:newValue ?? "")}
    }
}
