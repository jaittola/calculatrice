import Foundation

enum CalcError: Error {
    case divisionByZero(msgKey: String = "ErrDivByZero")
    case badInput(msgKey: String = "ErrBadInput")
    case unsupportedValueType(msgKey: String = "ErrUnsupportedValueType")
    case badCalculationOp(msgKey: String = "ErrBadCalculationOp")
    case nonIntegerInputToRational(msgKey: String =  "ErrNonIntegerInputToRational")
    case invalidComplexDimension(msgKey: String = "ErrInvalidComplexDimension")
}
