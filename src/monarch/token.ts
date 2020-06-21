/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { IState } from './types';

export class Token {
	_tokenBrand: void;

	public readonly offset: number;
	public readonly type: string;
	public readonly language: string;
	public value: string | null;
	public whitespace: string | null;
	public scope: any;
	public stack: any;

	constructor(offset: number, type: string, language: string) {
		this.offset = offset | 0;// @perf
		this.type = type;
		this.language = language;
		this.value = null;
		this.whitespace = null;
		this.stack = null;
	}

	public toString(): string {
		return this.value || ''; // '(' + this.offset + ', ' + this.type + ')';
	}

	public match(val: any): boolean {
        if(typeof val == 'string'){
            if(val.indexOf(' ') > 0){
                val = val.split(' ');
            } else if(this.type.indexOf(val) >= 0){
                return true;
            }
        }
        if(val instanceof Array){
            for(let item of val){
                if(this.type.indexOf(item) >= 0){ return true }
            }
        }
        if(val instanceof RegExp){
            return val.test(this.type);
        }
        return false;
    }
}

export class TokenizationResult {
	_tokenizationResultBrand: void;

	public readonly tokens: Token[];
	public readonly endState: IState;

	constructor(tokens: Token[], endState: IState) {
		this.tokens = tokens;
		this.endState = endState;
	}
}