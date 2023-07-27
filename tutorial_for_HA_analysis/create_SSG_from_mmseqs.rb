#!/usr/bin/ruby

fname = open(ARGV[0], "r")
faln = open(ARGV[1], "r")
fout = open(ARGV[2], "w")
seqnum = ARGV[3].to_i

#Create a hash table to convert accessions into index
accession_to_idx = Hash.new()
while line=fname.gets
	tmp = line.split("\t")
	accession_to_idx[tmp[0]] = tmp[1].chomp.to_i
end

#Gen alignment score from mmseqs result
score_inter = Array.new(seqnum).map{Array.new(seqnum,0)}
score_intra = Array.new(seqnum,0)
while line=faln.gets
	tmp = line.split("\t")
	sid1 = accession_to_idx[tmp[0]]
	sid2 = accession_to_idx[tmp[1]]
	score = tmp[2].to_f

	if sid1 == sid2
		score_intra[sid1] = score
	else
		score_inter[sid1][sid2] = score
	end
end

#calculate and save the SSG matrix
for i in 0..seqnum-1
	out = ""
	for j in 0..seqnum-1
		if score_intra[i] == 0 || score_intra[j] == 0
			out += "0\t"
		else
			out += "#{[score_inter[i][j],score_inter[j][i]].max/[score_intra[i],score_intra[j]].max}\t"
		end
	end
	fout.puts(out.chop)
end
fout.close()

