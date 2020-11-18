
acc <- function (x, d = 0) {
  
  formattable::accounting(
    x = x,
    digits = d,
    big.mark = ".",
    decimal.mark = ","
  )
  
}

