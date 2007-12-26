#ifndef HASHBLOOM_H_
#define HASHBLOOM_H_

#include "HashValue.h"

/**
 * According to http://www.eecs.harvard.edu/~michaelm/NEWWORK/postscripts/BloomFilterSurvey.pdf
 * the optimal number of hashes k is (m/n)*ln(2), m = number of bits in the filter and n = number
 * of items added. The largest k that we can get from a single TTH value depends on the number of 
 * bits we need to address the bloom structure, which in turn depends on m, so the optimal size
 * for our filter is m = n * k / ln(2) where n is the number of TTH values, or in our case, number of
 * files in share since each file is identified by one TTH value. We try that for each even dividend 
 * of the key size (2, 3, 4, 6, 8, 12) and if m fits within the bits we're able to address (2^(keysize/k)), 
 * we can use that value when requesting the bloom filter.
 */
class HashBloom {
public:
	/** Return a suitable value for k based on n */
	static size_t get_k(size_t n);
	/** Optimal number of bits to allocate for n elements when using k hashes */
	static uint64_t get_m(size_t n, size_t k);
	
	void add(const TTHValue& tth);
	bool match(const TTHValue& tth) const;
	void reset(ByteVector& v, size_t k);
	void push_back(bool v);
	
	size_t size() const { return bloom.size(); }
private:	
	
	size_t pos(const TTHValue& tth, size_t n) const;
	
	std::vector<bool> bloom;
	size_t k;
};

#endif /*HASHBLOOM_H_*/
