DOTS=$(wildcard *.dot)

.SUFFIXES: .dot .png

.PHONY: all
all: $(patsubst %.dot, %.png, $(DOTS))

.dot.png: $(DOTS)
	dot -Tpng $< > $@

.PHONY: clean
clean:
	rm -f *.png
