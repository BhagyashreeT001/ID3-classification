IsPure <- function(data) {
  length(unique(data[,ncol(data)])) == 1
}
Entropy <- function( vls ) {
  res <- vls/sum(vls) * log2(vls/sum(vls))
  res[vls == 0] <- 0
  -sum(res)
}
Entropy(c(10, 0))
Entropy(c(0, 10))
Entropy(c(5, 5))
entropy <- function(class) Entropy(c(class, 100 - class))
entropy <- Vectorize(entropy)
curve( entropy, from = 0, to = 100, xname = 'class')

InformationGain <- function( tble ) {
  tble <- as.data.frame.matrix(tble)
  entropyBefore <- Entropy(colSums(tble))
  s <- rowSums(tble)
  entropyAfter <- sum (s / sum(s) * apply(tble, MARGIN = 1, FUN = Entropy ))
  informationGain <- entropyBefore - entropyAfter
  return (informationGain)
}
require (dplyr)
library(data.tree)
data<-read.csv("C:/Users/LENOVO/Downloads/Shape1.csv")
#View(data)
tble <- table(data[,c('Form', 'Class')])
tble

InformationGain(tble)
InformationGain(table(data[,c('Color', 'Class')]))
InformationGain(table(data[,c('Size', 'Class')]))


TrainID3 <- function(node, data) {
  
  node$obsCount <- nrow(data)
  
  #if the data-set is pure (e.g. all toxic), then
  if (IsPure(data)) {
    #construct a leaf having the name of the pure feature (e.g. 'toxic')
    child <- node$AddChild(unique(data[,ncol(data)]))
    node$feature <- tail(names(data), 1)
    child$obsCount <- nrow(data)
    child$feature <- ''
  } else {
    #chose the feature with the highest information gain (e.g. 'color')
    ig <- sapply(colnames(data)[-ncol(data)], 
                 function(x) InformationGain(
                   table(data[,x], data[,ncol(data)])
                 )
    )
    feature <- names(ig)[ig == max(ig)][1]
    
    node$feature <- feature
    
    #take the subset of the data-set having that feature value
    childObs <- split(data[,!(names(data) %in% feature)], data[,feature], drop = TRUE)
    
    for(i in 1:length(childObs)) {
      #construct a child having the name of that feature value (e.g. 'red')
      child <- node$AddChild(names(childObs)[i])
      
      #call the algorithm recursively on the child and the subset      
      TrainID3(child, childObs[[i]])
    }
    
  }
  
  
  
}
tree <- Node$new("Shape")
TrainID3(tree, data)
print(tree, "feature", "obsCount")

Predict <- function(tree, features) {
  if (tree$children[[1]]$isLeaf) return (tree$children[[1]]$name)
  child <- tree$children[[features[[tree$feature]]]]
  return ( Predict(child, features))
}
Predict(tree, c(Form = 'triangle', 
                Color = 'yellow', 
                Size = 'big')
)

