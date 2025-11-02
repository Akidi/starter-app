export type NavChild = {
	name: string;
	href: string;
	description?: string;
	external?: boolean;
};

export type NavItem = {
	name: string;
	href?: string;
	external?: boolean;
	children?: NavChild[];
};
