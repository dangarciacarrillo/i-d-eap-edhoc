TARGETS_DRAFTS := draft-ingles-eap-edhoc 
TARGETS_TAGS := 
draft-ingles-eap-edhoc-00.md: draft-ingles-eap-edhoc.md
	sed -e 's/draft-ingles-eap-edhoc-latest/draft-ingles-eap-edhoc-00/g' $< >$@
