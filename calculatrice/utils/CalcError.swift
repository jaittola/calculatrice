import Foundation

enum CalcError: Error {
    case divisionByZero(msgKey: String = "ErrDivByZero")
    case badInput(msgKey: String = "ErrBadInput")
    case unsupportedValueType(msgKey: String = "ErrUnsupportedValueType")
    case badCalculationOp(msgKey: String = "ErrBadCalculationOp")
    case nonIntegerInputToRational(msgKey: String = "ErrNonIntegerInputToRational")
    case invalidComplexDimension(msgKey: String = "ErrInvalidComplexDimension")
    case arithmeticOverflow(msgKey: String = "ErrArithmeticOverflow")
    case pasteFailed(msgKey: String = "ErrPasteFailed")
    case unequalMatrixRowsCols(msgKey: String = "ErrUnequalMatrixRows")
    case errInputsMustBeMatrixes(msgKey: String = "ErrInputsMustBeMatrixes")
    case errBadMatrixDimensionsForMult(msgKey: String = "ErrBadMatrixDimensionsForMult")
    case errMatrixMustBeSquare(msgKey: String = "ErrMatrixMustBeSquare")
    case sameDimensionVectorsRequired(msgKey: String = "ErrSameDimensionVectorsRequired")
}
