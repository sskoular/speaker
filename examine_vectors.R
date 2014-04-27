setwd("/Users/sskoularikis/speaker")

args <- commandArgs(trailingOnly = TRUE)
# get the data
data = read.csv(args[1], header = FALSE)

n=nrow(data)
### VECTOR QUANTISATION (K-MEANS CLUSTERING)
k = 6
#k=round(sqrt(n/2))
indices<-round(runif(k)*(n-1))+1; # pick k vectors at random to be initial means
means<-data[indices,];
euclid_dist<-function(v1,v2) { # find euclidean distance btwn. 2 vectors
	sqrt(sum((v1-v2)^2))
}
assign<-function(data,means){ # assigns each frame to a cluster
	assgn <-c()
	for(i in seq(1,nrow(data))) {
		m<-c()
		for(j in seq(1,k)) m<-c(m,euclid_dist(data[i,],means[j,]))
		assgn<-c(assgn,which(m==min(m))[1])
	}
	assgn
}
update<-function(data,assgn){ # recalculate means based on frames in cluster
	avgs<-c()
	for(j in seq(1,k)){
		total<-rep(0,ncol(data))
		for(i in which(assgn==j)) total = total + data[i,]
		total = total/length(which(assgn==j))
		avgs<-rbind(avgs,total)
	}
	avgs
}
kmeans<-function(data,means_init) { # variation of EM
	assgn_init<-assign(data,means_init)
	assgn=assgn_init
	assgn_old=0
	while(identical(assgn,assgn_old)) { # has converged when assignments are unchanged
		means <- update(data,assgn)
		assgn_old <- assgn
		assgn <- assign(data,means)
	}
	list(means=means,assign=assgn)
}
codebook=kmeans(data,means)
row.names(codebook$means)<-seq(1,k)

### BAUM-WELCH RE-ESTIMATION
baumWelchRecursion<-function (hmm, observation) 
{
    TransitionMatrix = hmm$transProbs
    TransitionMatrix[, ] = 0
    EmissionMatrix = hmm$emissionProbs
    EmissionMatrix[, ] = 0
    f = forward(hmm, observation)
    b = backward(hmm, observation)
    probObservations = f[1, length(observation)]
    for (i in 2:length(hmm$States)) {
        j = f[i, length(observation)]
        if (j > -Inf) {
            probObservations = j + log(1 + exp(probObservations - 
                j))
        }
    }
    for (x in hmm$States) {
        for (y in hmm$States) {
            temp = f[x, 1] + log(hmm$transProbs[x, y]) + log(hmm$emissionProbs[y, 
                observation[1 + 1]]) + b[y, 1 + 1]
            for (i in 2:(length(observation) - 1)) {
                j = f[x, i] + log(hmm$transProbs[x, y]) + log(hmm$emissionProbs[y, 
                  observation[i + 1]]) + b[y, i + 1]
                if (j > -Inf) {
                  temp = j + log(1 + exp(temp - j))
                }
            }
            temp = exp(temp - probObservations)
            TransitionMatrix[x, y] = temp
        }
    }
    for (x in hmm$States) {
        for (s in hmm$Symbols) {
            temp = -Inf
            for (i in 1:length(observation)) {
                if (s == observation[i]) {
                  j = f[x, i] + b[x, i]
                  if (j > -Inf) {
                    temp = j + log(1 + exp(temp - j))
                  }
                }
            }
            temp = exp(temp - probObservations)
            EmissionMatrix[x, s] = temp
        }
    }
    return(list(TransitionMatrix = TransitionMatrix, EmissionMatrix = EmissionMatrix))
}

hack_baumWelch<-function (hmm, observation, maxIterations = 100, delta = 1e-09, 
    pseudoCount = 0) 
{
    tempHmm = hmm
    tempHmm$transProbs[is.na(hmm$transProbs)] = 0
    tempHmm$emissionProbs[is.na(hmm$emissionProbs)] = 0
    diff = c()
    for (i in 1:maxIterations) {
        bw = baumWelchRecursion(tempHmm, observation)
        T = bw$TransitionMatrix
        E = bw$EmissionMatrix
        T[!is.na(hmm$transProbs)] = T[!is.na(hmm$transProbs)] + 
            pseudoCount
        E[!is.na(hmm$emissionProbs)] = E[!is.na(hmm$emissionProbs)] + 
            pseudoCount
        T = (T/apply(T, 1, sum))
        E = (E/apply(E, 1, sum))
        d = sqrt(sum((tempHmm$transProbs - T)^2)) + sqrt(sum((tempHmm$emissionProbs - 
            E)^2))
        diff = c(diff, d)
        tempHmm$transProbs = T
        tempHmm$emissionProbs = E
        if (is.na(d)) {
        	break
        }
        if (is.na(delta)) {
        	break
        }
        if (d < delta) {
            break
        }
    }
    tempHmm$transProbs[is.na(hmm$transProbs)] = NA
    tempHmm$emissionProbs[is.na(hmm$emissionProbs)] = NA
    return(list(hmm = tempHmm, difference = diff))
}

#local({r <- getOption("repos"); r["CRAN"] <- "http://cran.r-project.org"; options(repos=r)})
#install.packages("HMM")
library(HMM)

trans_probs <- matrix(runif(k^2),k,k)
alpha <- .5*(.40*k - 1)
trans_probs <- trans_probs + alpha *diag(k)
for (i in seq(1,k)) {
	trans_probs[i,] <- trans_probs[i,]/sum(trans_probs[i,])
}

emit_probs <- matrix(runif(k^2),k,k)
for (i in seq(1,k)) {
	emit_probs[i,] <- emit_probs[i,]/sum(emit_probs[i,])
}

hmm <- initHMM(seq(1,k),seq(1,k),transProbs=trans_probs, emissionProbs=emit_probs) #initialize the HMM
bw <- hack_baumWelch(hmm, codebook$assign)

state_sequence <- viterbi(bw$hmm, codebook$assign) # find most likely sequence of states given the observations and the converged hmm

sink("temp2.txt")
cat(state_sequence)
sink()

where = paste("/Users/sskoularikis/speaker/plots/", substr(args[1], 1, nchar(args[1])-9),sep="")
where = paste(where, "_parcoord.png",sep="")
png(filename=where)

# Parallel coordinates plot to visualize k-means clustering of observation vectors
library(MASS)
rain=rainbow(k)
par(mfrow=c(2,1))
parcoord(data,col=rain[codebook$assign],main="Original Observations")
parcoord(means,col=rain,main="Extracted Feature Vectors")
graphics.off()




