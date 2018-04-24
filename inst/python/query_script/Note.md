# Perfomance problem

## Current state

- Due to iterative nature of the current library, query a large amount of data is less than optimal
- Test query of Curcuma dataset (80k entry) yield result of 10 hours
- Thus it is unrealistic to query any dataset that is larger than curcuma

## Solution

### Use Thread Pooling to optimize query

---

## Result

### For short test (14 entries)

````bash
(rrice) C:\Users\XPS 15-9550\Git\rRice_legacy\inst\python>python "query_script/curcuma.py"
Processing file Control-1-NT_25628_clustered_genes_annotations.1.tab

Iterative method: 11.544315814971924
Parallel method: 3.1708974838256836
````

The short test prove that major improvement by using thread pooling to wrap the query.

---

## Problems

- Might be difficult to implement for general case - see curcuma.py for example
- If leave it to biologist to implement on their own it could also be difficult
- Server register the queries as DDOS - Solve by reduce pool size - trade off for speed