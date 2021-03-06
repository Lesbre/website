# =============================
# Variables
# =============================

color = on
local = false

SRC = htmls
WWW = www
PPROC = pproc
CP = cp -r

URL = https://www.eleves.ens.fr/home/dlesbre
ALT_URL = https://www.eleves.ens.fr/~dlesbre

HTMLS = \
	index.html \
	cv.html \
	fichiers.html \

SSH = dlesbre@sas.eleves.ens.fr:www/

# =============================
# makefile code and variable setting
# =============================

ifeq ($(color),on)
	# Bold orange text
	color_s=\033[33;1m
	color_e=\033[38;22m
else
	color_s=
	color_e=
endif

ifeq ($(local),true)
	URL = $(shell pwd)/$(WWW)
	PP = $(PPROC) "-DURL=$(URL)" "-DALT_URL=$(ALT_URL)" -Ddefaultlang=fr -DDEBUG
else
	PP = $(PPROC) "-DURL=$(URL)" "-DALT_URL=$(ALT_URL)" -Ddefaultlang=fr -DRELEASE
endif

en = $(WWW)/en
fr = $(WWW)/fr

HTML_SOURCES = $(addprefix $(SRC)/, $(HTMLS))
HTML_TARGETS = $(WWW)/index.html $(addprefix $(en)/, $(HTMLS)) $(addprefix $(fr)/, $(HTMLS))

TARGETS = $(WWW)/sitemap.xml $(HTML_TARGETS)

DIRS = $(en) $(fr)

# =============================
# Default target
# =============================

default:

# =============================
# General rules
# =============================

$(fr)/%.html: $(SRC)/%.html $(SRC)/base.html $(SRC)/formatter.html | dirs
	echo "$(color_s)Rendering $@$(color_e)"
	$(PP) -DLANG=FR -o $@ $<

$(en)/%.html: $(SRC)/%.html $(SRC)/base.html $(SRC)/formatter.html | dirs
	echo "$(color_s)Rendering $@$(color_e)"
	$(PP) -DLANG=EN -o $@ $<

$(WWW)/index.html: $(SRC)/redirect.html $(SRC)/formatter.html
	echo "$(color_s)Rendering $@$(color_e)"
	$(PP) -o $@ $<

$(WWW)/sitemap.xml: sitemap.xml
	echo "$(color_s)Rendering $@$(color_e)"
	$(PP) -o $@ $<

# =============================
# Specific rules
# =============================

$(DIRS):
	echo "$(color_s)Making build directories$(color_e)"
	mkdir -p $(DIRS)

# =============================
# Special Targets
# =============================

# No display of executed commands.
$(VERBOSE).SILENT:

.PHONY: all clean dirs default firefox chromium sync

default: all
dirs: $(DIRS)
all: $(TARGETS)| dirs

firefox: all
	echo "$(color_s)Opening in firefox$(color_e)"
	firefox $(WWW)/index.html &

chromium: all
	echo "$(color_s)Opening in chromium$(color_e)"
	chromium $(WWW)/index.html &

clean:
	echo "$(color_s)Removing html files$(color_e)"
	rm -rf $(TARGETS) $(fr) $(en)

ifeq ($(local),true)
deploy:
	echo "$(color_s)ERROR : Should not deploy in local mode$(color_e)"
else
deploy: clean all
	echo "$(color_s)Deploying to online$(color_e)"
	rsync -rv ./www/ "$(SSH)"
endif
