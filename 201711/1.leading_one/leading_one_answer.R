set.seed(171111)

gen.mat <- function(dim, min=0, max=1){
  mat <- matrix(sample(min:max, dim^2, replace=TRUE), dim)
  rownames(mat) <- LETTERS[1:dim]
  colnames(mat) <- LETTERS[1:dim]
  mat
}

(adjmat <- gen.mat(dim=5))

# hint : t, apply, commax, diff

# 집계함수(mean, sum 등) 가 아닌 경우에 apply 를 적용하기 위함 : 원본 matrix dimension 유지
matrix.apply <- function(X, MARGIN, FUN){ 
  if(MARGIN==1) t(apply(X, MARGIN, FUN)) 
  else apply(X, MARGIN, FUN)
}

leading.one <- function(X, MARGIN){ 
  cummax.one <- matrix.apply(X, MARGIN, cummax) # cummax 함수를 적용하여 단조증가 행렬화 : 0, 1로 구성된 행렬 가정이므로
  remove.tail <- function(x) c(x[1], diff(x)) # 첫번째 등장하는 1만 남기는 함수 : 0밖에 없는 경우도 감안함
  matrix.apply(cummax.one, MARGIN, remove.tail) 
}

adjmat
leading.one(adjmat, 1)
leading.one(adjmat, 2)

# ===================

adjmat <- gen.mat(dim=5, min=0, max=2)

leading.num <- function(X, MARGIN){ 
  mask <- ifelse(X != 0, 1, 0) # non-zero 인 경우 1, 아닌경우 0으로 0과 1로 이진화
  ifelse(leading.one(mask, MARGIN) == 1, X, 0) # 앞서만든 leading.one 위치정보를 이용하여 첫 non-zero 숫자를 남김
}

adjmat
leading.num(adjmat, 1)
leading.num(adjmat, 2)