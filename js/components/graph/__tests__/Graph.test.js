import React from 'react';
import { mount } from 'enzyme';
import graphData from "./graphData";
import Graph from '../Graph'

let graph;

beforeAll(() => {
    const graphProps = {
        ...graphData,
        edit: false,
        initialDrawMode: "draw-node",
        initialOnDraw: false,
        start_blank: false
    }
    graph = mount(<Graph {...graphProps} />);
});

describe('Graph Node', () => {
    it('Hovering over a course node should make a info box appear', () => {
        const csc165 = graph.find('#csc165240');
        expect(graph.exists("g#infoBox")).toBe(false);
        expect(csc165.hasClass("takeable"));
        
        csc165.simulate('mouseover');
        expect(csc165.hasClass("missing"));
        expect(graph.exists("g#infoBox")).toBe(true);
        expect(graph.exists("g#tooltip-group")).toBe(true);

    });
    it('Pressing on the info box should create a new pop up', () => {

    });
    it('clicking a course node: triggers changes in the path and children nodes (including hybrid nodes)', () => {
        // before
        const hybridCSC165 = graph.find("g#h68"); // hardcoded
        const csc165 = graph.find('g#csc165240');
        const csc165To236 = graph.find('path[d="M497.651848,69.09890799999998 497.651848,130.885308 "]')  // extremely hard-coded
        expect(csc165.hasClass("takeable"));
        expect(csc165To236.hasClass("inactive"));
        expect(hybridCSC165.hasClass("inactive"));

        csc165.simulate('click');

        // after
        expect(csc165.hasClass("active"));
        expect(csc165To236.hasClass("takeable"));
        expect(hybridCSC165.hasClass("active"));

        // cleanup
        csc165.simulate('click');
        expect(csc165.hasClass("takeable"));
        expect(csc165To236.hasClass("inactive"));
        expect(hybridCSC165.hasClass("inactive"));
    });

    it("courses without the met pre-requisites should be inactive and not takeable", () => {
        const csc148 = graph.find('g#csc148');
        expect(csc148.hasClass("inactive"));
    });

    it("Clicking and hovering over Boolean and Hybrid nodes should do nothing", () => {
        // create a boolean node
        // create a hybrid node

        // hover over them
        // click them
    });

    it("Pressing a course node without the prerequisites should turn the node's border red (overriden class)", () => {
        // set CSC148 to be true
        // set CSC108 to be false
        // arrows going out of CSC148 should now be black instead of grey
        // arrows going out of CSC148 should be dotted, not solid
    });
});
