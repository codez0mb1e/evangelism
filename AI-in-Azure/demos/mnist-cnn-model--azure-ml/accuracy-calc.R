input <- maml.mapInputPort(1)

feat <- data.matrix(input[, 2:11])

total <- sum(sum(feat))
correct <- sum(diag(feat))

result <- data.frame(accuracy = correct/total)

maml.mapOutputPort("result");