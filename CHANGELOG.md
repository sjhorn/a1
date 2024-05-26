## 2.0.0
- Breaking changes on comparison of [A1], to provide deterministic binary searches
- Addition of [A1RangeBinarySearch] that features a binary search across mutliple [A1Range]s for a match
- Simplified [A1Range], [A1] and [A1Partial] to use rectangle-like logic, even for unbounded ranges
- Adding left,top,right,bottom as well as columnSpan and rowSpan to [A1Range]
- Refactored numerous tests to match the new more deterministic logic for comparisons, column/row matches

## 1.1.0

- Add features for A1Range to selection single border for left,top,right,bottom of range
- Fix range [A1Range] comparison to compare whole single/multi-column, single/multi-whole row, whole sheet
- Bug fix [A1Range] hashCode for range A1:A1, as this would return zero (0) for single value ranges like A1:A1, B2:B2
- Add intersect, subtract and overlayRanges to assist with formatting ranges in a worksheet
- Worthy of a minor version bump to 1.1.0

## 1.0.13

- Bug fix for hasRow, hasColumn for whole columns/rows ie. A:A, 1:1 cases
- Add features to check if a partial represents a whole row or column or either
- Add A1Range.all and A1Partial.all to support these single use-cases

## 1.0.12

- Fixeg bug in hasCorner or the A:A, 2:2 cases ie. whole row or column selection

## 1.0.11

- Add hasRow/Column method for A1Range to help with showing selection in a spreadsheet UI
- Fixed bug that didn't allow parsing A1Range A:C (cols)

## 1.0.10

- Add method for A1Range to check if an A1 is in one of its corners, typically a suitable place for an anchor cell

## 1.0.9

- Fix edge case in a A1Range where the FROM has a greater column than the TO

## 1.0.8

- Enhanced A1Range with an optional anchor cell

## 1.0.7

- Enhanced A1Range with fromA1s method.
- Enhanced A1Partial with fromA1 method.

## 1.0.6

- Enhanced A1Partial to accept a vector
- Moved the int to A1 Letters into an extension on int

## 1.0.5

- Added testing is an A1 is in an A1Range with contains method
- Slight tweak on comparing a A1Partial eg. A with 1, it will now use the larger index rather than have A always be larger
- Adjusted tests for above tweak

## 1.0.4

- Added support for A1 mapping as an extension on Map<String,String> to Map<A1,A1> to assist with A1 moves

## 1.0.3

- Added support for A1 as an extension on Set to simplify creating an a1 set from String 

## 1.0.2

- Added A1Range and A1Reference examples to readme and example
- Adjusted area to be a double for A1 and build this into a range
- Fixed minor bug with parsing a partial range in a reference
- Added github action build pipeline with coverage
- Move test coverage to 100%

## 1.0.1

- Minor fixes in docs and imports
- Added icon

## 1.0.0

- Initial version that implements 
