import { cityServiceAt } from './city-doors.js';
import { podServiceAt } from './city-pod.js';
import { validateCampaignPod } from './campaign-pod.js';
import { validateShipResources } from './ship-resources.js';
import { depotPrices, quoteDepotService, purchaseDepotService } from './depot.js';

function setup(state,content,geometry) {
  const driving=state.pod.occupied,{travel,start}=state;
  if(travel.scene!=='depot'||cityServiceAt(geometry.map,travel.cityPosition,driving?'pod':'foot')!=='depot'||
    (driving&&podServiceAt(geometry.pod,travel.cityPosition,state.pod.heading)!=='depot'))throw new Error('depotUnavailable');
  validateCampaignPod(state.pod,travel,geometry.pod);
  const resources=validateShipResources(state.resources,start),location=start.playerLocation;
  const system=content.dialogue?.systems.systems.find(s=>s.id===location.systemId);
  const account=state.economy.accounts.find(a=>a.systemId===location.systemId);
  if(!system||!account)throw new Error('depotUnavailable');
  const visit={local12:system.local31,local13:system.local30,local14:system.local32,
    cityId:location.cityId,worldId:location.worldId,
    shipPresent:start.shipLocation.cityId===location.cityId&&start.shipLocation.worldId===location.worldId&&start.shipLocation.systemId===location.systemId,
    podPresent:driving};
  return {visit,session:{hull:resources.hull,fuel:resources.fuel,cash:state.dialogue.cash,bankBalance:account.balance,pod:state.pod.cargo}};
}

export function campaignDepotOffers(state,content,geometry) {
  const {session,visit}=setup(state,content,geometry),prices=depotPrices(visit,session.hull);
  return ['refuel','repair','auxiliary'].map(type=>{
    const maximum=type==='refuel'?16-Math.trunc((session.fuel+1)/16):type==='repair'?16-session.hull:session.pod.filter(c=>c===null).length;
    const present=type==='auxiliary'?visit.podPresent:visit.shipPresent;
    return {type,unitPrice:prices[type],maximum,
      affordable:present?Math.min(maximum,Math.floor((session.cash+session.bankBalance)/prices[type])):0,
      reason:!present?'depotVehicleAbsent':maximum===0?'depotCapacity':prices[type]>session.cash+session.bankBalance?'depotInsufficient':''};
  });
}
export function campaignDepotQuote(state,content,geometry,type,units) {
  const {session,visit}=setup(state,content,geometry);
  return quoteDepotService(session,visit,type,units);
}
export function reduceCampaignDepot(previous,content,geometry,action) {
  const {session,visit}=setup(previous,content,geometry);
  const paid=purchaseDepotService(session,visit,action),next=structuredClone(previous);
  next.resources.hull=paid.hull;next.resources.fuel=paid.fuel;next.pod.cargo=paid.pod;
  next.dialogue.cash=paid.cash;next.economy.accounts.find(a=>a.systemId===previous.start.playerLocation.systemId).balance=paid.bankBalance;
  return next;
}
