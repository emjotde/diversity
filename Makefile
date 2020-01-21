SHELL=/bin/bash
DIR_GUARD=@mkdir -p $(@D)

SRC=en
TGT=de

all: allpairs

download/wmt19-submitted-data-v3-txt-minimal.tgz : 
	$(DIR_GUARD)
	curl 'http://ufallab.ms.mff.cuni.cz/~bojar/wmt19/wmt19-submitted-data-v3-txt-minimal.tgz' --output $@

download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019 : download/wmt19-submitted-data-v3-txt-minimal.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<)

download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019/$(SRC)-$(TRG) : download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019 

data/wmt19/$(SRC)-$(TGT) : download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf $^ $@

data/wmt19/$(SRC)-$(TGT)/newstest2019.HUMAN.$(SRC)-$(TGT) : download/wmt19-submitted-data-v3/txt/references/newstest2019-$(SRC)$(TGT)-ref.$(TGT) data/wmt19/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf $< $@

results/wmt19.$(SRC)-$(TGT).mtld.txt : data/wmt19/$(SRC)-$(TGT) data/wmt19/$(SRC)-$(TGT)/newstest2019.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt19/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		cat $$output | perl scripts/mtld.pl $(TGT); \
	done | perl -pe 's/data\/wmt19\/$(SRC)-$(TGT)\/newstest2019.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt19.$(SRC)-$(TGT).ttr.txt : data/wmt19/$(SRC)-$(TGT) data/wmt19/$(SRC)-$(TGT)/newstest2019.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt19/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		cat $$output | perl scripts/ttr.pl $(TGT); \
	done | perl -pe 's/data\/wmt19\/$(SRC)-$(TGT)\/newstest2019.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt19.$(SRC)-$(TGT).%.cor.txt : results/wmt19.$(SRC)-$(TGT).%.txt human-eval/ad-sys-ranking-$(SRC)-$(TGT)-z.csv
	paste <(sort -k1,1 $(word 1, $^)) <(sort -k5,5 $(word 2, $^)) -d ' ' | grep -v task | cut -f 2,4 -d ' ' | perl scripts/correlation.pl > $@

results.wmt19.$(SRC)-$(TGT): \
	results/wmt19.$(SRC)-$(TGT).mtld.txt \
	results/wmt19.$(SRC)-$(TGT).mtld.cor.txt \
	results/wmt19.$(SRC)-$(TGT).ttr.txt \
	results/wmt19.$(SRC)-$(TGT).ttr.cor.txt

clean:
	rm -rf download data results

onepair: results.wmt19.$(SRC)-$(TGT)

allpairs: download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019
	$(MAKE) onepair SRC=de TGT=en
	$(MAKE) onepair SRC=en TGT=cs
	$(MAKE) onepair SRC=en TGT=de
	$(MAKE) onepair SRC=en TGT=fi
	$(MAKE) onepair SRC=en TGT=gu
	$(MAKE) onepair SRC=en TGT=kk
	$(MAKE) onepair SRC=en TGT=lt
	$(MAKE) onepair SRC=en TGT=ru
	$(MAKE) onepair SRC=en TGT=zh
	$(MAKE) onepair SRC=fi TGT=en
	$(MAKE) onepair SRC=gu TGT=en
	$(MAKE) onepair SRC=lt TGT=en
	$(MAKE) onepair SRC=ru TGT=en
	$(MAKE) onepair SRC=kk TGT=en
	$(MAKE) onepair SRC=zh TGT=en
