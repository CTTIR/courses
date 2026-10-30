import test from 'node:test';
import assert from 'node:assert/strict';
import {createState, makeMatcher} from '../assets/js/overview/state.js';
import {createGraph, bindResetButton} from '../assets/js/overview/graph.js';

test('shared URLs clamp dates and hydration replaces previous filters', () => {
  global.location = {search:'?from=2026&to=-1&topics=old&q=old', pathname:'/overview.html', hash:''};
  global.history = {replaceState(){}};
  const controller = createState({minYear:0,maxYear:0});
  controller.hydrateFromURL();
  assert.equal(controller.state.dateFrom,0);
  assert.equal(controller.state.dateTo,0);
  global.location.search = '';
  controller.hydrateFromURL();
  assert.equal(controller.isActive(),false);
  assert.equal(makeMatcher(controller.state,null)({year:0,tags:[],labels:[]}),true);
});

test('range inputs remain ordered within their bounds', () => {
  const c=createState({minYear:2020,maxYear:2026});
  c.setRange(2025,2022);
  assert.deepEqual([c.state.dateFrom,c.state.dateTo],[2022,2025]);
  c.setRange(NaN,Infinity);
  assert.deepEqual([c.state.dateFrom,c.state.dateTo],[2020,2026]);
});

test('network failure still permits reset and list filtering', () => {
  const container={};
  const graph=createGraph({container});
  let click;
  bindResetButton({addEventListener:(_,fn)=>{click=fn;}},graph);
  assert.match(container.textContent,/failed to load/);
  assert.doesNotThrow(()=>{click();graph.update({});});
});
