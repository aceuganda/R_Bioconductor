
## Working with Vectors

1. Consider two numeric vectors `p<-c(2,4,6)` and `q<-c(3,5,7)`. Perform the following operations on `p` and `q`.
    * Add `p` and `q`
    * Subtract `p` from `q`
    * multiply `p` by `q`
    * divide `p` by `q`
    * raise `p` to the power of `q`

2. Repeat (1) with `p<-c(4,8,5)` and `q<-c(3,2)`. Inspect any warnings or errors and examine how `R` handles arithmetic operations for vectors of different length.

3. Create a vector `x` of even numbers between 3 and 99.
    * Compute the average, variance, standard deviation, median,
    lower quartile, upper quartile, highest and lowest element of `x`.
    * Create a vector `y` with elements of vector `x` sorted in decreasing order. 
    * Create a vector `z` with ranks of elements of vector `x`.

4. Given a numeric vector `a<-c(2,8,3,NA,8,13,NA,16,4,2,8,5)`.
    * Use `R` to count the number of missing values in `a`.
    * Create a vector `b` containing non-missing values of `a`.
    * Create a vector `d` by replacing missing values of `a` with 0.
    * Create a vector `f` by replacing missing values with a random selected number from vector `b`.

5. Consider two character vectors `x<-"Bioinformatics at Makerere"` and `y<-"Semester I 2020/2021"`.
    * Use R to count the number of characters in `x`.
    * Extract the word "Bioinformatics" from `x`.
    * Combine `x` and `y` to form the statement "Bioinformatics at Makerere, Semester I 2020".
