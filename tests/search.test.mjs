import test from 'node:test';
import assert from 'node:assert/strict';
import {createSearch} from '../assets/js/overview/search.js';
const graph = {nodes: [{id:'course1/lab_week1_session1',url:'course1_foundations/labs/lab_week1_session1.html'}]};
function fixture(loadModule) {
  const input = {value:'',addEventListener(){}};
  global.document = {baseURI:'https://example.org/courses/overview.html', getElementById:()=>input};
  const results=[];
  return {results,search:createSearch({root:'./',graph,controller:{},onResults:r=>results.push(r),loadModule})};
}
const hit = {results:[{data:async()=>({url:'/courses/course1_foundations/labs/lab_week1_session1.html',excerpt:'sample'})}]};
test('index resolves from the document site root and maps prefixed URLs',async()=>{
  let url;const {search,results}=fixture(async u=>{url=u;return {search:async()=>hit}});
  await search.update({query:'sample'});
  assert.equal(url,'https://example.org/courses/pagefind/pagefind.js');
  assert.deepEqual([...results[0].hits],['course1/lab_week1_session1']);
});
test('an old result cannot replace a newer query or cleared search',async()=>{
  const pending=new Map();const {search,results}=fixture(async()=>({search:q=>new Promise(resolve=>pending.set(q,resolve))}));
  const old=search.update({query:'old'});await new Promise(setImmediate);
  const latest=search.update({query:'latest'});await new Promise(setImmediate);
  pending.get('latest')({results:[]});await latest;
  pending.get('old')(hit);await old;
  assert.equal(results.length,1);assert.equal(results[0].hits.size,0);
  const next=search.update({query:'slow'});await new Promise(setImmediate);
  await search.update({query:''});pending.get('slow')(hit);await next;
  assert.equal(results.length,2);assert.equal(results[1].hits,null);
});
test('index load failure is visible and the next query can retry',async()=>{
  let attempts=0;const {search,results}=fixture(async()=>{if(!attempts++)throw Error('offline');return {search:async()=>hit}});
  await search.update({query:'first'});assert.match(results[0].error,/could not load/);
  await search.update({query:'second'});assert.equal(results[1].hits.size,1);
});
test('query failure has a visible recovery instruction',async()=>{
  const {search,results}=fixture(async()=>({search:async()=>{throw Error('bad index')}}));
  await search.update({query:'x'});assert.match(results[0].error,/Clear the search/);
});
