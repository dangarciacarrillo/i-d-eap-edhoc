TARGETS_DRAFTS := draft-ingles-eap-edhoc 
TARGETS_TAGS := 
draft-ingles-eap-edhoc-00.txt: draft-ingles-eap-edhoc.txt
	sed -e 's/draft-ingles-eap-edhoc-latest/draft-ingles-eap-edhoc-00/g' -e 's/draft-ingles-eap-edhoc-latest/draft-ingles-eap-edhoc-00/g' -e 's/draft-ingles-eap-edhoc-latest/draft-ingles-eap-edhoc-00/g' $< >$@
